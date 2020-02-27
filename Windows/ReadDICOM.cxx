#include <vtkSmartPointer.h>
#include <vtkImageViewer2.h>
#include <vtkImageAppend.h>
#include <vtkDICOMImageReader.h>
#include <vtkRenderWindow.h>
#include <vtkRenderWindowInteractor.h>
#include <vtkOBJExporter.h>
#include <vtkExporter.h>
#include <vtkImageData.h>
#include <vtkRenderer.h>
#include <vector>
#include <Windows.h>
#include <vtkPolyDataMapper.h>
#include <vtkPolyData.h>
#include <vtkInteractorStyleTrackballCamera.h>




int main(int argc, char* argv[])
{
  /*  // Verify input arguments
    if (argc != 2)
    {
        std::cout << "Usage: " << argv[0]
            << " Filename(.img)" << std::endl;
        return EXIT_FAILURE;
    }*/

    std::string folder = "./patient/";
    std::vector<std::string> files;
    std::string search_path = folder + "/*.*";
    WIN32_FIND_DATA fd;
    HANDLE hFind = ::FindFirstFile(search_path.c_str(), &fd);
    if (hFind != INVALID_HANDLE_VALUE) {
        do {
            // read all (real) files in current folder
            // , delete '!' read other 2 default folder . and ..
            if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                files.push_back(fd.cFileName);
            }
        } while (::FindNextFile(hFind, &fd));
        ::FindClose(hFind);
    }
    
    std::vector<vtkDataObject*> images;
    // Read all the DICOM files in the specified directory. 
    vtkSmartPointer<vtkImageAppend> imageAppend = vtkSmartPointer<vtkImageAppend>::New();
    imageAppend->SetAppendAxis(2);

    for (int i = 0; i < files.size(); i++) {
        vtkSmartPointer<vtkDICOMImageReader> reader =
            vtkSmartPointer<vtkDICOMImageReader>::New();
        reader->SetFileName(("./patient/" + files.at(i)).c_str());
        reader->Update();
        imageAppend->AddInputData(reader->GetOutput());
       // vtkDataObject* image = reader->GetInput();
        //images.push_back(image);
    }
    /*

    for (int i = 0; i < images.size(); i++)
    {
       imageAppend->SetInputData(i,images.at(i));
    }*/

    imageAppend->Update();

    //vtkOBJExporter
   // vtkSmartPointer<vtkRenderer> renderer;
    //renderer = vtkRenderer::New();
    vtkSmartPointer<vtkPolyData> model = vtkPolyData::New();
    model->DeepCopy(imageAppend->GetOutput());
    vtkSmartPointer<vtkPolyDataMapper> myDataMapper = vtkPolyDataMapper::New();
    myDataMapper->SetInputData(model);
    vtkActor* myActor = vtkActor::New();
    myActor->SetMapper(myDataMapper);

    /*
    //assign our actor to the renderer
    renderer->AddActor(myActor);
    std::string temp = "test";
    vtkRenderWindow* renWin = vtkRenderWindow::New();
    renWin->AddRenderer(renderer);
    vtkSmartPointer<vtkOBJExporter> objExporter = vtkOBJExporter::New();
    objExporter->SetRenderWindow(renWin);
    objExporter->SetFilePrefix(temp.c_str());
    objExporter->Update();
    objExporter->Write();*/


    // Create an actor

    // A renderer and render window
    vtkSmartPointer<vtkRenderer> renderer =
        vtkSmartPointer<vtkRenderer>::New();
    vtkSmartPointer<vtkRenderWindow> renderWindow =
        vtkSmartPointer<vtkRenderWindow>::New();
    renderWindow->AddRenderer(renderer);

    // An interactor
    vtkSmartPointer<vtkRenderWindowInteractor> renderWindowInteractor =
        vtkSmartPointer<vtkRenderWindowInteractor>::New();
    renderWindowInteractor->SetRenderWindow(renderWindow);

    renderer->AddActor(myActor);
    renderer->SetBackground(1, 1, 1); // Background color white

    // Render
    renderWindow->Render();

    /*vtkSmartPointer<vtkInteractorStyleTrackballCamera> style =
        vtkSmartPointer<vtkInteractorStyleTrackballCamera>::New(); //like paraview

    renderWindowInteractor->SetInteractorStyle(style);*/

    // Begin mouse interaction
    renderWindowInteractor->Start();

  


    return EXIT_SUCCESS;
}

