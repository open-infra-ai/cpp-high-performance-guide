# GEMM stage cross-correctness tests. The parallel stage falls back to simd
# without OpenMP (see include/hpc/gemm.hpp), so the test itself builds and
# passes either way; only the OpenMP link is conditional, matching the
# ENABLE_OPENMP guard in _hpc_configure_target.

add_executable(gemm_test
    gemm_test.cpp
)

target_link_libraries(gemm_test PRIVATE
    GTest::gtest
    GTest::gtest_main
    hpc_headers
)

if(OpenMP_CXX_FOUND)
    target_link_libraries(gemm_test PRIVATE OpenMP::OpenMP_CXX)
endif()

hpc_set_compiler_options(gemm_test)
hpc_enable_sanitizers(gemm_test)
hpc_enable_simd(gemm_test AVX2)

gtest_add_tests(TARGET gemm_test)
