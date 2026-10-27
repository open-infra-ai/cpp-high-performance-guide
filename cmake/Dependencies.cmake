# Dependencies.cmake
# Manages external dependencies using FetchContent
# This is the modern CMake approach - no need for git submodules or manual downloads

include(FetchContent)

# Set FetchContent to be quiet by default
set(FETCHCONTENT_QUIET ON)
# Keep preset reconfiguration stable and avoid unnecessary remote updates once
# dependencies have been fetched locally or in CI workspaces.
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

#------------------------------------------------------------------------------
# Google Benchmark
#------------------------------------------------------------------------------
function(hpc_fetch_google_benchmark)
    message(STATUS "Fetching Google Benchmark...")
    
    FetchContent_Declare(
        benchmark
        GIT_REPOSITORY https://github.com/google/benchmark.git
        GIT_TAG        v1.8.3
        GIT_SHALLOW    TRUE
    )
    
    # Disable benchmark tests to speed up build
    set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
    
    FetchContent_MakeAvailable(benchmark)
    
    message(STATUS "Google Benchmark fetched successfully")
endfunction()

#------------------------------------------------------------------------------
# Google Test
#------------------------------------------------------------------------------
function(hpc_fetch_google_test)
    message(STATUS "Fetching Google Test...")
    
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        v1.14.0
        GIT_SHALLOW    TRUE
    )
    
    # For Windows: Prevent overriding the parent project's compiler/linker settings
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
    
    FetchContent_MakeAvailable(googletest)
    
    message(STATUS "Google Test fetched successfully")
endfunction()

#------------------------------------------------------------------------------
# RapidCheck (Property-based testing)
#------------------------------------------------------------------------------
function(hpc_fetch_rapidcheck)
    message(STATUS "Fetching RapidCheck...")

    # No GIT_SHALLOW here: shallow clones cannot resolve a pinned commit SHA
    # once upstream master moves past it ("reference is not a tree").
    FetchContent_Declare(
        rapidcheck
        GIT_REPOSITORY https://github.com/emil-e/rapidcheck.git
        GIT_TAG        b2d9ed2dddefc4b84318d664b4f221eb792d89c7
    )
    
    # Enable GTest integration
    set(RC_ENABLE_GTEST ON CACHE BOOL "" FORCE)
    set(RC_ENABLE_GMOCK ON CACHE BOOL "" FORCE)

    FetchContent_MakeAvailable(rapidcheck)

    # Treat rapidcheck's headers as SYSTEM includes: warnings inside the
    # pinned third-party commit (e.g. -Wconversion in Numeric.hpp) are not
    # actionable here and drown out warnings in our own code. CMake 3.25+
    # could pass SYSTEM to FetchContent_Declare directly; this repo supports
    # 3.20, so mark the target's declared include dirs as SYSTEM instead.
    # INTERFACE_SYSTEM_INCLUDE_DIRECTORIES is a marker over the dirs already
    # listed in INTERFACE_INCLUDE_DIRECTORIES (same genex strings), not an
    # independent source of includes — the same pattern googletest uses to
    # get -isystem for its consumers.
    get_target_property(rc_includes rapidcheck INTERFACE_INCLUDE_DIRECTORIES)
    if(rc_includes)
        set_property(TARGET rapidcheck
            PROPERTY INTERFACE_SYSTEM_INCLUDE_DIRECTORIES ${rc_includes})
    endif()

    message(STATUS "RapidCheck fetched successfully")
endfunction()
