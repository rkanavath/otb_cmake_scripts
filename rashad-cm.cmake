#rashad-cm.cmake - custom cmake scripts for travis build
#before running this script you need to set the below env variables
#export CC=/usr/local/bin/clang
#export CXX=/usr/local/bin/clang++
#export CMAKE_CMD=/usr/local/bin/cmake
#export XDK_DIR=/tmp/OTB-xdk-Linux64

set(ENV{LC_ALL} C)

set(CTEST_SITE "travis-ci.org")
set(CTEST_DASHBOARD_TRACK Continuous)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_DASHBOARD_ROOT "/home/travis/build")
#set(CTEST_DASHBOARD_ROOT "/tmp/temp")
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/orfeotoolbox/OTB")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/orfeotoolbox/build")
set(CMAKE_MAKE_PROGRAM "$ENV{MAKE_CMD}")
set(CMAKE_COMMAND "$ENV{CMAKE_CMD}")
set(CTEST_CMAKE_GENERATOR "$ENV{CMAKE_GEN}")

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)
set(CTEST_TEST_TIMEOUT 1500)

set(CTEST_USE_LAUNCHERS TRUE)

execute_process(COMMAND "${CMAKE_COMMAND}" -E chdir ${CTEST_SOURCE_DIRECTORY} "git" "branch" OUTPUT_VARIABLE GIT_BRANCH RESULT_VARIABLE rv)
if(NOT rv EQUAL 0)
message(WARNING "cannot find git branch")
set(GIT_BRANCH "develop")
else()
string(REPLACE "\n" "" GIT_BRANCH ${GIT_BRANCH})
string(REGEX REPLACE "^\\*" "" GIT_BRANCH ${GIT_BRANCH})
string(REGEX REPLACE ".detached.from.*\\)" "" GIT_BRANCH ${GIT_BRANCH})
endif()
set(CTEST_BUILD_NAME "travis-${GIT_BRANCH}")

#set(OTB_C_FLAGS "-DCMAKE_C_FLAGS:STRING=-Wall -Wno-gnu -Wno-uninitialized  -Wno-unused-variable")
#list(APPEND OTB_C_FLAGS  "-DCMAKE_CXX_FLAGS:STRING=-Wall  -Wno-gnu -Wno-deprecated -Wno-uninitialized -Wno-overloaded-virtual -Wno-unused-parameter")

#set(CTEST_TEST_ARGS INCLUDE_LABEL "")

#OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/otb-data

set(cmake_configure_option_list)
foreach(opt ${cmake_configure_options})
  list(APPEND cmake_configure_option_list "-D${opt}")
endforeach()

#disable tests
set(dashboard_no_test TRUE)

#empty binary directory
#ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

#call ctest_start
ctest_start(${CTEST_DASHBOARD_TRACK} TRACK ${CTEST_DASHBOARD_TRACK})

#run configure
ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY}
  SOURCE ${CTEST_SOURCE_DIRECTORY}
  OPTIONS "-DCMAKE_PREFIX_PATH:PATH=/tmp/OTB-xdk-Linux64;-DBUILD_TESTING:BOOL=ON;-DCMAKE_CXX_FLAGS='-w';-DCMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION};-DSITE:STRING=${CTEST_SITE};-DBUILDNAME:STRING=${CTEST_BUILD_NAME};-DCMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM};-DCTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS};-DDART_TESTING_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}")

#read custom files
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

#build OTB
ctest_build()

#run test if asked explicitly
if(NOT dashboard_no_test)
    ctest_test(${CTEST_TEST_ARGS})
endif()

#submit to dashboard
ctest_submit()
