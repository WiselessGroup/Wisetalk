//! Pictures for chats, prepared on this device before they are encrypted:
//! photos are scaled down and re-encoded, which also drops their metadata
//! (camera, place). Animated GIFs go as they are. The same rules as the web
//! client's picture.ts, except that photos become JPEG rather than WebP.

use std::io::Cursor;

use anyhow::{Context, bail};
use image::codecs::jpeg::JpegEncoder;
use image::imageops::FilterType;
use image::{DynamicImage, ImageFormat, ImageReader, RgbaImage};
use wisetalk_core::api::AVATAR_MAX_BYTES;
use wisetalk_core::protocol::{CHAT_IMAGE_MAX_BYTES, CHAT_IMAGE_MAX_SIDE, CHAT_IMAGE_SCALE_TO};

/// A picture ready to encrypt and send.
pub struct Picture {
    pub bytes: Vec<u8>,
    /// Its media type, one of the chat's picture types.
    pub kind: String,
    pub width: u32,
    pub height: u32,
}

/// Reads a picture file and makes it fit to send. Slow on big photos: runs
/// off the UI thread.
pub fn prepare_picture(bytes: Vec<u8>) -> anyhow::Result<Picture> {
    let reader = ImageReader::new(Cursor::new(&bytes)).with_guessed_format()?;
    let format = match reader.format() {
        Some(f @ (ImageFormat::Jpeg | ImageFormat::Png | ImageFormat::Gif | ImageFormat::WebP)) => {
            f
        }
        _ => bail!("Only pictures can go into a chat."),
    };
    if format == ImageFormat::Gif {
        let (width, height) = ImageReader::new(Cursor::new(&bytes))
            .with_guessed_format()?
            .into_dimensions()
            .context("This picture can't be read.")?;
        if bytes.len() <= CHAT_IMAGE_MAX_BYTES
            && width <= CHAT_IMAGE_MAX_SIDE
            && height <= CHAT_IMAGE_MAX_SIDE
        {
            return Ok(Picture {
                bytes,
                kind: "image/gif".into(),
                width,
                height,
            });
        }
    }
    fit(reader.decode().context("This picture can't be read.")?)
}

/// The picture on the clipboard, prepared like [prepare_picture]; `None`
/// when the clipboard holds something else.
pub fn clipboard_picture() -> anyhow::Result<Option<Picture>> {
    #[cfg(any(target_os = "linux", target_os = "windows", target_os = "macos"))]
    {
        let Ok(copied) = arboard::Clipboard::new()?.get_image() else {
            return Ok(None);
        };
        let pixels = RgbaImage::from_raw(
            copied.width.try_into()?,
            copied.height.try_into()?,
            copied.bytes.into_owned(),
        )
        .context("This picture can't be read.")?;
        Ok(Some(fit(DynamicImage::ImageRgba8(pixels))?))
    }
    #[cfg(not(any(target_os = "linux", target_os = "windows", target_os = "macos")))]
    Ok(None)
}

/// Scales a decoded picture down and encodes it to send.
fn fit(image: DynamicImage) -> anyhow::Result<Picture> {
    let longest = image.width().max(image.height());
    let image = if longest > CHAT_IMAGE_SCALE_TO {
        let scale = f64::from(CHAT_IMAGE_SCALE_TO) / f64::from(longest);
        let width = ((f64::from(image.width()) * scale).round() as u32).max(1);
        let height = ((f64::from(image.height()) * scale).round() as u32).max(1);
        image.resize_exact(width, height, FilterType::CatmullRom)
    } else {
        image
    };
    let (width, height) = (image.width(), image.height());
    let mut out = Vec::new();
    // Pictures with transparency stay PNG; everything else is a photo.
    // Clipboard pictures always carry an alpha channel, mostly unused.
    let transparent =
        image.color().has_alpha() && image.to_rgba8().pixels().any(|pixel| pixel.0[3] < u8::MAX);
    let kind = if transparent {
        image.write_to(&mut Cursor::new(&mut out), ImageFormat::Png)?;
        "image/png"
    } else {
        image
            .to_rgb8()
            .write_with_encoder(JpegEncoder::new_with_quality(&mut out, 88))?;
        "image/jpeg"
    };
    if out.len() > CHAT_IMAGE_MAX_BYTES {
        bail!("This picture is too large.");
    }
    Ok(Picture {
        bytes: out,
        kind: kind.into(),
        width,
        height,
    })
}

/// An account's picture, as the web client makes it: the middle square of
/// a picture, at most 256 pixels wide, as JPEG (PNG when it has
/// transparency). Returns the bytes and their media type.
pub fn prepare_avatar(bytes: Vec<u8>) -> anyhow::Result<(Vec<u8>, String)> {
    let image = ImageReader::new(Cursor::new(&bytes))
        .with_guessed_format()?
        .decode()
        .context("This picture can't be read.")?;
    let side = image.width().min(image.height());
    let image = image.crop_imm(
        (image.width() - side) / 2,
        (image.height() - side) / 2,
        side,
        side,
    );
    let image = if side > AVATAR_SIDE {
        image.resize_exact(AVATAR_SIDE, AVATAR_SIDE, FilterType::CatmullRom)
    } else {
        image
    };
    let transparent =
        image.color().has_alpha() && image.to_rgba8().pixels().any(|pixel| pixel.0[3] < u8::MAX);
    let mut out = Vec::new();
    let kind = if transparent {
        image.write_to(&mut Cursor::new(&mut out), ImageFormat::Png)?;
        "image/png"
    } else {
        JpegEncoder::new_with_quality(&mut out, 90).encode_image(&image.to_rgb8())?;
        "image/jpeg"
    };
    if out.len() > AVATAR_MAX_BYTES {
        bail!("This picture is too big even after scaling it down.");
    }
    Ok((out, kind.into()))
}

/// Pixels on a side of an account's picture.
const AVATAR_SIDE: u32 = 256;

#[cfg(test)]
mod tests {
    use super::*;
    use image::{DynamicImage, RgbImage, RgbaImage};

    fn encode(image: DynamicImage, format: ImageFormat) -> Vec<u8> {
        let mut out = Vec::new();
        image.write_to(&mut Cursor::new(&mut out), format).unwrap();
        out
    }

    #[test]
    fn big_photos_shrink_to_jpeg() {
        let photo = encode(
            DynamicImage::ImageRgb8(RgbImage::new(4000, 2000)),
            ImageFormat::Png,
        );
        let picture = prepare_picture(photo).unwrap();
        assert_eq!((picture.width, picture.height), (2560, 1280));
        assert_eq!(picture.kind, "image/jpeg");
        assert_eq!(&picture.bytes[..2], [0xff, 0xd8]);
    }

    #[test]
    fn transparent_pictures_stay_png() {
        let shot = encode(
            DynamicImage::ImageRgba8(RgbaImage::new(300, 200)),
            ImageFormat::Png,
        );
        let picture = prepare_picture(shot).unwrap();
        assert_eq!((picture.kind.as_str(), picture.width), ("image/png", 300));
    }

    #[test]
    fn gifs_go_as_they_are() {
        let gif = encode(
            DynamicImage::ImageRgba8(RgbaImage::new(40, 30)),
            ImageFormat::Gif,
        );
        let picture = prepare_picture(gif.clone()).unwrap();
        assert_eq!(picture.bytes, gif);
        assert_eq!((picture.width, picture.height), (40, 30));
    }

    #[test]
    fn other_files_are_refused() {
        assert!(prepare_picture(b"%PDF-1.7".to_vec()).is_err());
    }
}
