//! Pictures for chats, prepared on this device before they are encrypted:
//! photos are scaled down and re-encoded, which also drops their metadata
//! (camera, place). Animated GIFs go as they are. The same rules as the web
//! client's picture.ts, except that photos become JPEG rather than WebP.

use std::io::Cursor;

use anyhow::{Context, bail};
use image::codecs::jpeg::JpegEncoder;
use image::imageops::FilterType;
use image::{ImageFormat, ImageReader};
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
    let image = reader.decode().context("This picture can't be read.")?;
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
    // Screenshots with transparency stay PNG; everything else is a photo.
    let kind = if image.color().has_alpha() {
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
