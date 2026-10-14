# Swaps the libwebrtc that flutter_webrtc bundles for a newer build.
#
# flutter_webrtc 1.6.2 ships libwebrtc m150.7871.03. Since m150 WebRTC fixes
# its logging configuration on the first log line, with INFO on stderr in
# every build type, and at INFO the frame encryptor prints the call key and
# the key derived from it (webrtc-sdk/webrtc#308). Nothing the app can call
# turns that off in time. m150.7871.04 keeps release builds silent again
# (webrtc-sdk/libwebrtc#153) and exports the same functions with the same
# headers, so the app ships it in place of .03.
#
# Drop this file once flutter_webrtc bundles .04 or later: the check below
# fails the build when the bundled version changes.
#
# Include after flutter/generated_plugins.cmake. Expects WISETALK_LIBWEBRTC_OS
# (linux or win) and WISETALK_LIBWEBRTC_ARCH (x64 or arm64).

set(_replaces "libwebrtc.m150.7871.03")
set(_version "libwebrtc.m150.7871.04")
set(_hash_linux-x64 "39efac2abd9b4ef6c1088f098d8ae8f1e62c7d8726b61344ac73ac8d748ad319")
set(_hash_linux-arm64 "5490f26d2ab3bb2108c349162453623ab00c5723fc144e9ca77fcfff78805dc2")
set(_hash_win-x64 "3bc70034b62cfba19ff24c1a30c7768832990713198038bf9cc56de70c3974cb")
set(_hash_win-arm64 "99b5ba304e077151e47e70f5a92450292563effc38de7538c2b67f610ab74a9d")

if(WISETALK_LIBWEBRTC_OS STREQUAL "win")
  set(_library "libwebrtc.dll")
else()
  set(_library "libwebrtc.so")
endif()

# The bundled copy, as flutter_webrtc lists it.
set(_bundled "")
foreach(_path IN LISTS PLUGIN_BUNDLED_LIBRARIES)
  get_filename_component(_name "${_path}" NAME)
  if(_name STREQUAL _library)
    set(_bundled "${_path}")
  endif()
endforeach()
if(_bundled STREQUAL "")
  message(FATAL_ERROR "libwebrtc: flutter_webrtc no longer bundles ${_library}; revisit cmake/libwebrtc.cmake")
endif()

get_filename_component(_third_party "${_bundled}/../../.." ABSOLUTE)
file(STRINGS "${_third_party}/libwebrtc_version.ini" _bundled_version
  REGEX "^binary_version *=")
string(REGEX REPLACE "^binary_version *= *" "" _bundled_version "${_bundled_version}")
string(STRIP "${_bundled_version}" _bundled_version)
if(NOT _bundled_version STREQUAL _replaces)
  message(FATAL_ERROR "libwebrtc: flutter_webrtc now bundles ${_bundled_version}, not ${_replaces}. "
    "Check that it keeps call keys out of the logs, then drop cmake/libwebrtc.cmake.")
endif()

set(_asset "libwebrtc-${WISETALK_LIBWEBRTC_OS}-${WISETALK_LIBWEBRTC_ARCH}-release")
set(_hash "${_hash_${WISETALK_LIBWEBRTC_OS}-${WISETALK_LIBWEBRTC_ARCH}}")
if(_hash STREQUAL "")
  message(FATAL_ERROR "libwebrtc: no ${_version} build for ${WISETALK_LIBWEBRTC_OS}-${WISETALK_LIBWEBRTC_ARCH}")
endif()

# Archives name their top directory differently per platform, so the library
# is found by its place inside it.
set(_dir "${CMAKE_BINARY_DIR}/${_version}/${_asset}")
file(GLOB _replacement "${_dir}/*/lib/${_library}")
if(_replacement STREQUAL "")
  message(NOTICE "libwebrtc: downloading ${_version} for ${_asset}")
  set(_zip "${CMAKE_BINARY_DIR}/${_version}/${_asset}.zip")
  file(DOWNLOAD
    "https://github.com/webrtc-sdk/libwebrtc/releases/download/${_version}/${_asset}.zip"
    "${_zip}"
    EXPECTED_HASH SHA256=${_hash}
    STATUS _status)
  list(GET _status 0 _code)
  if(NOT _code EQUAL 0)
    message(FATAL_ERROR "libwebrtc: download failed: ${_status}")
  endif()
  file(REMOVE_RECURSE "${_dir}")
  file(ARCHIVE_EXTRACT INPUT "${_zip}" DESTINATION "${_dir}")
  file(REMOVE "${_zip}")
  file(GLOB _replacement "${_dir}/*/lib/${_library}")
  if(_replacement STREQUAL "")
    message(FATAL_ERROR "libwebrtc: ${_asset}.zip has no lib/${_library}")
  endif()
endif()

# Rebuilt by hand: the plugin's path holds a "+", which list(TRANSFORM)
# would read as a regular expression.
set(_libraries "")
foreach(_path IN LISTS PLUGIN_BUNDLED_LIBRARIES)
  if(_path STREQUAL _bundled)
    list(APPEND _libraries "${_replacement}")
  else()
    list(APPEND _libraries "${_path}")
  endif()
endforeach()
set(PLUGIN_BUNDLED_LIBRARIES "${_libraries}")
