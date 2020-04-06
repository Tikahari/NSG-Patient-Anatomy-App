import vtk
import sys
import os
import time

def getch():
  import sys, tty, termios
  old_settings = termios.tcgetattr(0)
  new_settings = old_settings[:]
  new_settings[3] &= ~termios.ICANON
  try:
    termios.tcsetattr(0, termios.TCSANOW, new_settings)
    ch = sys.stdin.read(1)
  finally:
    termios.tcsetattr(0, termios.TCSANOW, old_settings)
  return ch

reader = vtk.vtkDICOMImageReader()
reader.SetDirectoryName(sys.argv[1])
reader.Update()

shiftScale = vtk.vtkImageShiftScale()
shiftScale.SetInputConnection(reader.GetOutputPort())
shiftScale.SetShift(0)
shiftScale.SetScale(.15)
shiftScale.SetOutputScalarTypeToUnsignedChar()

view = vtk.vtkImageViewer2()
view.SetSize(600,600)
view.SetInputConnection(shiftScale.GetOutputPort())
view.Render()
sl = 0
import sys, tty, termios


while True:
    if getch() == 'a':
        print('up')
        sl = sl+1
        view.SetSlice(sl)
    if getch() == ' ':
        print('down')
        sl = sl-1
        view.SetSlice(sl)
