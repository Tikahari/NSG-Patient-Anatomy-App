cmake_minimum_required(VERSION 3.3 FATAL_ERROR)

project(ReadDICOMSeries)
set(VTK_DIR "/home/tkhanal/projects/VTK-build")
find_package(VTK COMPONENTS 
  vtkCommonCore
  vtkIOImage
  vtkInteractionImage
  vtkInteractionStyle
  vtkRenderingCore
  vtkRenderingFreeType
  vtkRenderingOpenGL2 QUIET)
if (NOT VTK_FOUND)
  message("Skipping ReadDICOMSeries: ${VTK_NOT_FOUND_MESSAGE}")
  return ()
endif()
message (STATUS "VTK_VERSION: ${VTK_VERSION}")
if (VTK_VERSION VERSION_LESS "8.90.0")
  # old system
  include(${VTK_USE_FILE})
  add_executable(ReadDICOMSeries MACOSX_BUNDLE ReadDICOMSeries.cxx )
  target_link_libraries(ReadDICOMSeries PRIVATE ${VTK_LIBRARIES})
else ()
  # include all components
  add_executable(ReadDICOMSeries MACOSX_BUNDLE ReadDICOMSeries.cxx )
  target_link_libraries(ReadDICOMSeries PRIVATE ${VTK_LIBRARIES})
  # vtk_module_autoinit is needed
  vtk_module_autoinit(
    TARGETS ReadDICOMSeries
    MODULES ${VTK_LIBRARIES}
    )
endif () 
