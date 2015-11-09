#before running this script you need to set the below enviroment variables
#export CC=/usr/local/bin/clang
#export CXX=/usr/local/bin/clang++
#export CMAKE_CMD=/usr/local/bin/cmake
#export XDK_DIR=/tmp/OTB-xdk-Linux64

set(ENV{LC_ALL} C)

set(CTEST_SITE "travis-ci.org")
set(CTEST_DASHBOARD_TRACK Continuous)

set(CTEST_DASHBOARD_ROOT "/tmp/temp")
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/orfeotoolbox/OTB")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/orfeotoolbox/build")

set(GIT_BRANCH "develop")
set(CTEST_BUILD_NAME "travis-${CTEST_DASHBOARD_TRACK}-${GIT_BRANCH}")

set(CTEST_CMAKE_GENERATOR "Ninja")
set(CMAKE_MAKE_PROGRAM "/tmp/ninja")
set(CTEST_COMMAND "$ENV{CMAKE_CMD}")
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_BUILD_COMMAND "${CMAKE_MAKE_PROGRAM}" )
set(CTEST_CMAKE_GENERATOR "Ninja")

#set(CTEST_TEST_ARGS INCLUDE_LABEL "")

set(dashboard_cache "
CMAKE_C_COMPILER=$ENV{CC}
CMAKE_CXX_COMPILER=$ENV{CXX}
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized  -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-gnu -Wno-overloaded-virtual -Wno-cpp -Wno-unused-parameter
CMAKE_PREFIX_PATH:PATH=$ENV{XDK_DIR}
CMAKE_INSTALL_PREFIX=${CTEST_DASHBOARD_ROOT}/orfeotoolbox/install
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF
#OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/otb-data
")


file(WRITE ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt "
SITE:STRING=${CTEST_SITE}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
DART_TESTING_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
${dashboard_cache}
")



set(dashboard_no_test TRUE)










ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

ctest_start(${CTEST_DASHBOARD_TRACK} TRACK ${CTEST_DASHBOARD_TRACK})

ctest_configure()

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})


# ctest_build()

# if(NOT dashboard_no_test)
#    ctest_test(${CTEST_TEST_ARGS})
# endif()

if(NOT dashboard_no_submit)
  ctest_submit()
endif()
