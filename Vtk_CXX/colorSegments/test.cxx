#include <vtkSmartPointer.h>
#include <vtkRenderWindow.h>
#include <vtkRenderWindowInteractor.h>
#include <vtkRenderer.h>
#include <vtkActor.h>
#include <vtkNIFTIImageReader.h>
#include <vtkPolyDataMapper.h>
#include <vtkGPUVolumeRayCastMapper.h>
#include <vtkVolumeProperty.h>
#include <vtkColorTransferFunction.h>
#include <vtkImageData.h>
#include <vtkAlgorithm.h>
#include <vtkAlgorithm.h>
#include<vtkPointData.h>
#include<vtkDataArray.h>
#include <vtkPiecewiseFunction.h>
#include <unordered_map>
#include <tuple>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream> 

std::unordered_map<std::string, std::tuple<int,int,int,int>> getColorMap()
{
   std::unordered_map<std::string, std::tuple<int,int,int,int>> colorMap;
   std::string aseg = "/home/michael/New Folder/vtkC/ModifiedLUT.txt";
   std::ifstream file(aseg);
  std::string str;
  while (std::getline(file, str)) {
      int label, red, green, blue;
     std::string name;
     std::stringstream ss(str);
     ss >> label >> name >> red >> green >> blue;
     //std::cout << label << "\t" << name << "\t" << red << "\t" << green << "\t" << blue << "\t" << endl;
    colorMap.emplace(name,std::make_tuple(label,red,green,blue) );
  }
  return colorMap;
}

   


//not Really using this func
vtkSmartPointer<vtkVolume> getVolume(std::string filename,int labelNum, double r, double g, double b)
{
   vtkSmartPointer<vtkGPUVolumeRayCastMapper> volumeMapper = vtkSmartPointer<vtkGPUVolumeRayCastMapper>::New();
   vtkSmartPointer<vtkNIFTIImageReader> reader = vtkSmartPointer<vtkNIFTIImageReader>::New();
   reader->SetFileName(filename.c_str()); 
   reader->Update();
   volumeMapper->SetInputConnection(reader->GetOutputPort());
   volumeMapper->SetAutoAdjustSampleDistances(1);
    volumeMapper->SetSampleDistance(0.5);
       std::cout << "test4" << endl;
       vtkSmartPointer<vtkVolumeProperty> volumeProperty = vtkSmartPointer<vtkVolumeProperty>::New();
       volumeProperty->SetShade(1);
       volumeProperty->SetInterpolationTypeToLinear();

        vtkSmartPointer<vtkColorTransferFunction> ctf = vtkSmartPointer<vtkColorTransferFunction>::New();

        vtkSmartPointer<vtkPiecewiseFunction> pwf = vtkSmartPointer<vtkPiecewiseFunction>::New();

       pwf->AddPoint(0,0);
       pwf->AddPoint(2, 0);
       pwf->AddPoint(2, 255);
       pwf->AddPoint(5, 255);
      ctf->AddRGBPoint(3,r,g,b);
      volumeProperty->SetScalarOpacity(pwf);
      volumeProperty->SetColor(ctf); 
      


       //reendering
   vtkSmartPointer<vtkVolume> volume = vtkSmartPointer<vtkVolume>::New();
   volume->SetMapper(volumeMapper);
    volume->SetProperty(volumeProperty);
    return volume;
}

vtkSmartPointer<vtkVolume> getVolume(std::string filename, std::unordered_map<std::string, std::tuple<int,int,int,int>> colorMap)
{
   vtkSmartPointer<vtkGPUVolumeRayCastMapper> volumeMapper = vtkSmartPointer<vtkGPUVolumeRayCastMapper>::New();
   vtkSmartPointer<vtkNIFTIImageReader> reader = vtkSmartPointer<vtkNIFTIImageReader>::New();
   reader->SetFileName(filename.c_str()); 
   reader->Update();
   volumeMapper->SetInputConnection(reader->GetOutputPort());
   volumeMapper->SetAutoAdjustSampleDistances(1);
    volumeMapper->SetSampleDistance(0.5);
       std::cout << "test4" << endl;
       vtkSmartPointer<vtkVolumeProperty> volumeProperty = vtkSmartPointer<vtkVolumeProperty>::New();
       volumeProperty->SetShade(1);
       volumeProperty->SetInterpolationTypeToLinear();

        vtkSmartPointer<vtkColorTransferFunction> ctf = vtkSmartPointer<vtkColorTransferFunction>::New();

        vtkSmartPointer<vtkPiecewiseFunction> pwf = vtkSmartPointer<vtkPiecewiseFunction>::New();

       pwf->AddPoint(0,0);
       pwf->AddPoint(2,0);
       pwf->AddPoint(3, .3);
       pwf->AddPoint(40, .3);
       pwf->AddPoint(41, 0);
       pwf->AddPoint(42, .3);
       pwf->AddPoint(255, .3);
      pwf->AddPoint(256, .0);
      //pwf->AddPoint(9999999, .0);
      ctf->SetColorSpaceToRGB();
      for (std::pair<std::string,std::tuple<int,int,int,int>> element : colorMap)
      {
         std::tuple<int,int,int,int> color = element.second;
         if(std::get<0>(color) < 16000)
         {
            if(std::get<0>(color) == 2 || std::get<0>(color) == 41)
               continue;
         std::cout << element.first << "\t" << std::get<0>(color) << "\t" << std::get<1>(color) << "\t" << std::get<2>(color) << "\t" << std::get<3>(color) << "\t" << endl;
         ctf->AddRGBPoint(std::get<0>(color),std::get<1>(color)/255.0,std::get<2>(color)/255.0,std::get<3>(color)/255.0);
      }
         }
      volumeProperty->SetScalarOpacity(pwf);
      volumeProperty->SetColor(ctf);
   vtkSmartPointer<vtkVolume> volume = vtkSmartPointer<vtkVolume>::New();
   volume->SetMapper(volumeMapper);
    volume->SetProperty(volumeProperty);
    return volume;
}

int main()
{
//std::string aseg = "/home/michael/freesurfer/subjects/ourData/mri/aseg.nii";
std::string aseg = "/home/michael/freesurfer/subjects/ourData/mri/aparc.a2009s+aseg.nii";
std::unordered_map<std::string, std::tuple<int,int,int,int>> colorMap = getColorMap();
vtkSmartPointer<vtkVolume> v = getVolume(aseg, colorMap);
   vtkSmartPointer<vtkRenderer> renderer =
      vtkSmartPointer<vtkRenderer>::New();
         renderer->AddVolume(v);

         renderer->SetBackground2(0.2,0.3,0.4);
         renderer->SetBackground(0.1,0.1,0.1);
         renderer->GradientBackgroundOn();
         renderer->ResetCamera();
      vtkSmartPointer<vtkRenderWindow> renderWindow =
      vtkSmartPointer<vtkRenderWindow>::New();
   renderWindow->AddRenderer(renderer);

   vtkSmartPointer<vtkRenderWindowInteractor> renderWindowInteractor =
      vtkSmartPointer<vtkRenderWindowInteractor>::New();
   renderWindowInteractor->SetRenderWindow(renderWindow);


   renderWindow->Render();
   renderWindowInteractor->Start();

}
