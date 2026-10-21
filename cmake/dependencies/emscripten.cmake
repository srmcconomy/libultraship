include(FetchContent)

# Emscripten ships SDL2, zlib, libpng, bzip2, ogg and vorbis as ports. They are
# enabled with -sUSE_* flags instead of find_package, so wrap them in the
# imported targets the rest of the build links against.
set(EMSCRIPTEN_PORT_FLAGS -sUSE_SDL=2 -sUSE_SDL_NET=2 -sUSE_ZLIB=1 -sUSE_LIBPNG=1 -sUSE_BZIP2=1 -sUSE_OGG=1 -sUSE_VORBIS=1)

if (NOT TARGET SDL2::SDL2)
    add_library(SDL2::SDL2 INTERFACE IMPORTED GLOBAL)
    target_compile_options(SDL2::SDL2 INTERFACE ${EMSCRIPTEN_PORT_FLAGS})
    target_link_options(SDL2::SDL2 INTERFACE ${EMSCRIPTEN_PORT_FLAGS})
endif()
set(SDL2_FOUND TRUE)

#=================== nlohmann-json ===================
find_package(nlohmann_json QUIET)
if (NOT ${nlohmann_json_FOUND})
    FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.12.0
        OVERRIDE_FIND_PACKAGE
    )
    FetchContent_MakeAvailable(nlohmann_json)
endif()

#=================== tinyxml2 ===================
find_package(tinyxml2 QUIET)
if (NOT ${tinyxml2_FOUND})
    set(tinyxml2_BUILD_TESTING OFF)
    FetchContent_Declare(
        tinyxml2
        GIT_REPOSITORY https://github.com/leethomason/tinyxml2.git
        GIT_TAG 11.0.0
        OVERRIDE_FIND_PACKAGE
    )
    FetchContent_MakeAvailable(tinyxml2)
endif()

#=================== spdlog ===================
find_package(spdlog QUIET)
if (NOT ${spdlog_FOUND})
    FetchContent_Declare(
        spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.16.0
        OVERRIDE_FIND_PACKAGE
    )
    FetchContent_MakeAvailable(spdlog)
endif()

#=================== libzip ===================
find_package(libzip QUIET)
if (NOT ${libzip_FOUND})
    set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
    set(BUILD_TOOLS OFF)
    set(BUILD_REGRESS OFF)
    set(BUILD_EXAMPLES OFF)
    set(BUILD_DOC OFF)
    set(BUILD_OSSFUZZ OFF)
    set(BUILD_SHARED_LIBS OFF)
    set(ENABLE_COMMONCRYPTO OFF)
    set(ENABLE_GNUTLS OFF)
    set(ENABLE_MBEDTLS OFF)
    set(ENABLE_OPENSSL OFF)
    set(ENABLE_WINDOWS_CRYPTO OFF)
    set(ENABLE_LZMA OFF)
    set(ENABLE_ZSTD OFF)
    FetchContent_Declare(
        libzip
        GIT_REPOSITORY https://github.com/nih-at/libzip.git
        GIT_TAG v1.11.4
        OVERRIDE_FIND_PACKAGE
    )
    FetchContent_MakeAvailable(libzip)
    list(APPEND ADDITIONAL_LIB_INCLUDES ${libzip_SOURCE_DIR}/lib ${libzip_BINARY_DIR})
endif()

target_link_libraries(ImGui PUBLIC SDL2::SDL2)

# Ahead of the real thread-pool header: runs tasks inline since there are no threads
list(PREPEND ADDITIONAL_LIB_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/cmake/dependencies/emscripten)
target_compile_definitions(ImGui PUBLIC IMGUI_IMPL_OPENGL_ES3)

if (NOT TARGET SDL2_net::SDL2_net)
    add_library(SDL2_net::SDL2_net INTERFACE IMPORTED GLOBAL)
    target_link_libraries(SDL2_net::SDL2_net INTERFACE SDL2::SDL2)
endif()
set(SDL2_net_FOUND TRUE)
