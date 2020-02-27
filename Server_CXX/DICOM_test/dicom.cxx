#include <stdio.h>
#include <itkImage.h>
#include <itkGDCMImageIO.h>
#include <itkGDCMSeriesFileNames.h>
#include <itkImageSeriesReader.h>
#include <itkImageFileWriter.h>
#include <itkSTLMeshIO.h>

int main(int argc, char** argv){
    if(argc != 2){
        printf("Usage: ./dicomtest <DICOM Folder>\n");
        return 0;
    }
    printf("reading from %s\n", argv[1]);
    using PixelType = signed short;
    constexpr unsigned int Dimension = 3;
    //imagetype will be 3d image with pixeltype commonly used in dicom files
    using ImageType = itk::Image< PixelType, Dimension >;

    //our reader will be set up according to our imagetype
    using ReaderType = itk::ImageSeriesReader< ImageType >;
    ReaderType::Pointer reader = ReaderType::New();
    
    //grassroots dicom input output will be our image i/o type
    using ImageIOType = itk::GDCMImageIO;
    ImageIOType::Pointer dicomIO = ImageIOType::New();
    
    //set the i/o type of our reader
    reader->SetImageIO( dicomIO );
    
    //namesGenerator will deal with organizing the dicom files in the specified folder
    using NamesGeneratorType = itk::GDCMSeriesFileNames;
    NamesGeneratorType::Pointer nameGenerator = NamesGeneratorType::New();
    nameGenerator->SetUseSeriesDetails( true );
    nameGenerator->AddSeriesRestriction("0008|0021" );
    nameGenerator->SetDirectory( argv[1] );
    
    //every dicom series has an unique uid
    //seriesUID will be a reference to a vector of UID (only the first of which will describe our dicom series)
    using SeriesIdContainer = std::vector< std::string >;
    const SeriesIdContainer & seriesUID = nameGenerator->GetSeriesUIDs();
    std::string seriesIdentifier = seriesUID.begin()->c_str();

    //fileNames will be a vector of strings containing all the filenames in the specified directory
    using FileNamesContainer = std::vector< std::string >;
    FileNamesContainer fileNames = nameGenerator->GetFileNames( seriesIdentifier );

    //pass the files to the image reader
    reader->SetFileNames(fileNames);
    //Update() will 'trigger' the reading process
    reader->Update();

    //configure image writer to write stl (3d object file) as output
    itk::STLMeshIOFactory::RegisterOneFactory();
    using itk::QuadEdgeMesh<PixelType, Dimension>    QEMeshType;
    using itk::MeshFileWriter< QEMeshType >          WriterType;
    WriterType::Pointer writer = WriterType::New();
    writer->SetFileName("test.obj");
    writer->SetFileTypeAsASCII();

    //write the data in reader to a 3d file called 'test.obj'
    // using WriterType = itk::ImageFileWriter< ImageType >;
    // WriterType::Pointer writer = WriterType::New();

    writer->SetInput( reader->GetOutput() );
    //Update() 'triggers' the writing process
    writer->Update();
    printf("Done\n");
    return 0;
}DICOM