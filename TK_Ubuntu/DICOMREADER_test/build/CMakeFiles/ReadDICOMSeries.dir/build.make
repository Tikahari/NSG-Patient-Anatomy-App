# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.17

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/tkhanal/Desktop/DICOMREADER_test

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/tkhanal/Desktop/DICOMREADER_test/build

# Include any dependencies generated for this target.
include CMakeFiles/ReadDICOMSeries.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/ReadDICOMSeries.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/ReadDICOMSeries.dir/flags.make

CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.o: CMakeFiles/ReadDICOMSeries.dir/flags.make
CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.o: ../ReadDICOMSeries.cxx
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/tkhanal/Desktop/DICOMREADER_test/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.o"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.o -c /home/tkhanal/Desktop/DICOMREADER_test/ReadDICOMSeries.cxx

CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/tkhanal/Desktop/DICOMREADER_test/ReadDICOMSeries.cxx > CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.i

CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/tkhanal/Desktop/DICOMREADER_test/ReadDICOMSeries.cxx -o CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.s

# Object files for target ReadDICOMSeries
ReadDICOMSeries_OBJECTS = \
"CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.o"

# External object files for target ReadDICOMSeries
ReadDICOMSeries_EXTERNAL_OBJECTS =

ReadDICOMSeries: CMakeFiles/ReadDICOMSeries.dir/ReadDICOMSeries.cxx.o
ReadDICOMSeries: CMakeFiles/ReadDICOMSeries.dir/build.make
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkInteractionImage-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkRenderingOpenGL2-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkInteractionStyle-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkIOImage-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkRenderingFreeType-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkfreetype-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkzlib-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkRenderingUI-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkRenderingCore-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkFiltersCore-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkCommonExecutionModel-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkCommonDataModel-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkCommonMisc-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkglew-8.90.so.8.90.0
ReadDICOMSeries: /usr/lib/x86_64-linux-gnu/libGLX.so
ReadDICOMSeries: /usr/lib/x86_64-linux-gnu/libOpenGL.so
ReadDICOMSeries: /usr/lib/x86_64-linux-gnu/libXt.so
ReadDICOMSeries: /usr/lib/x86_64-linux-gnu/libX11.so
ReadDICOMSeries: /usr/lib/x86_64-linux-gnu/libICE.so
ReadDICOMSeries: /usr/lib/x86_64-linux-gnu/libSM.so
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkCommonTransforms-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkCommonMath-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtkCommonCore-8.90.so.8.90.0
ReadDICOMSeries: /home/tkhanal/projects/VTK-build/lib/libvtksys-8.90.so.8.90.0
ReadDICOMSeries: CMakeFiles/ReadDICOMSeries.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/tkhanal/Desktop/DICOMREADER_test/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable ReadDICOMSeries"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/ReadDICOMSeries.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/ReadDICOMSeries.dir/build: ReadDICOMSeries

.PHONY : CMakeFiles/ReadDICOMSeries.dir/build

CMakeFiles/ReadDICOMSeries.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/ReadDICOMSeries.dir/cmake_clean.cmake
.PHONY : CMakeFiles/ReadDICOMSeries.dir/clean

CMakeFiles/ReadDICOMSeries.dir/depend:
	cd /home/tkhanal/Desktop/DICOMREADER_test/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/tkhanal/Desktop/DICOMREADER_test /home/tkhanal/Desktop/DICOMREADER_test /home/tkhanal/Desktop/DICOMREADER_test/build /home/tkhanal/Desktop/DICOMREADER_test/build /home/tkhanal/Desktop/DICOMREADER_test/build/CMakeFiles/ReadDICOMSeries.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/ReadDICOMSeries.dir/depend

