#include <vtkSmartPointer.h>
#include <vtkImageViewer2.h>
#include <vtkImageAppend.h>
#include <vtkDICOMImageReader.h>
#include <vtkRenderWindow.h>
#include <vtkRenderWindowInteractor.h>
#include <vtkImageData.h>
#include <vtkRenderer.h>
#include <vector>
#include <Windows.h>




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


    // Visualize
    vtkSmartPointer<vtkImageViewer2> imageViewer =
        vtkSmartPointer<vtkImageViewer2>::New();
    imageViewer->SetInputConnection(imageAppend->GetOutputPort());
    vtkSmartPointer<vtkRenderWindowInteractor> renderWindowInteractor =
        vtkSmartPointer<vtkRenderWindowInteractor>::New();
    imageViewer->SetupInteractor(renderWindowInteractor);
    imageViewer->Render();
    imageViewer->GetRenderer()->ResetCamera();
    imageViewer->Render();

    renderWindowInteractor->Start();

    return EXIT_SUCCESS;
}

