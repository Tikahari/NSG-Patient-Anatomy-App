cmake_minimum_required(VERSION 2.8)

PROJECT(ReadDICOM)

find_package(VTK REQUIRED)
include(${VTK_USE_FILE})

add_executable(ReadDICOM MACOSX_BUNDLE ReadDICOM.cxx)

if(VTK_LIBRARIES)
  target_link_libraries(ReadDICOM ${VTK_LIBRARIES})
else()
  target_link_libraries(ReadDICOM vtkHybrid vtkWidgets)
endif()