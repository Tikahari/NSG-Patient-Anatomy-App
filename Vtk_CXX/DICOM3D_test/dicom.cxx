#include <itkImage.h>
#include <itkGDCMImageIO.h>
#include <itkGDCMSeriesFileNames.h>
#include <itkImageSeriesReader.h>
#include <itkImageFileWriter.h>

int
main(int argc, char * argv[])
{
  if (argc < 2)
  {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " [DicomDirectory  [outputFileName  [seriesName]]]";
    std::cerr << "\nIf DicomDirectory is not specified, current directory is used\n";
  }
  std::string dirName = "."; // current directory by default
  if (argc > 1)
  {
    dirName = argv[1];
  }

  //set image type to 3d and correct pixel type
  using PixelType = signed short;
  constexpr unsigned int Dimension = 3;
  using ImageType = itk::Image<PixelType, Dimension>;

  //nameGenerator will hold the names of the dicom files in the given directory
  using NamesGeneratorType = itk::GDCMSeriesFileNames;
  NamesGeneratorType::Pointer nameGenerator = NamesGeneratorType::New();

  //initialize properties that will tell us how to read the directory
  nameGenerator->SetUseSeriesDetails(true);
  nameGenerator->AddSeriesRestriction("0008|0021");
  nameGenerator->SetGlobalWarningDisplay(false);
  nameGenerator->SetDirectory(dirName);


  try
  {
      //get seriesUID (unique for every dicom series)
    using SeriesIdContainer = std::vector<std::string>;
    const SeriesIdContainer & seriesUID = nameGenerator->GetSeriesUIDs();
    auto                      seriesItr = seriesUID.begin();
    auto                      seriesEnd = seriesUID.end();

    //print info about directory
    if (seriesItr != seriesEnd)
    {
      std::cout << "The directory: ";
      std::cout << dirName << std::endl;
      std::cout << "Contains the following DICOM Series: ";
      std::cout << std::endl;
    }
    else
    {
      std::cout << "No DICOMs in: " << dirName << std::endl;
      return EXIT_SUCCESS;
    }
    //print files
    while (seriesItr != seriesEnd)
    {
      std::cout << seriesItr->c_str() << std::endl;
      ++seriesItr;
    }

    //iterate through files again
    seriesItr = seriesUID.begin();
    while (seriesItr != seriesUID.end())
    {
      //set or get series identifier (seriesUID)
      std::string seriesIdentifier;
      if (argc > 3) // If seriesIdentifier given convert only that
      {
        seriesIdentifier = argv[3];
        seriesItr = seriesUID.end();
      }
      else // otherwise convert everything
      {
        seriesIdentifier = seriesItr->c_str();
        seriesItr++;
      }
      std::cout << "\nReading: ";
      //declare variables that will store filenames and image info (reader)
      std::cout << seriesIdentifier << std::endl;
      using FileNamesContainer = std::vector<std::string>;
      FileNamesContainer fileNames = nameGenerator->GetFileNames(seriesIdentifier);
      
      //initialize properties of image reader
      using ReaderType = itk::ImageSeriesReader<ImageType>;
      ReaderType::Pointer reader = ReaderType::New();
      using ImageIOType = itk::GDCMImageIO;
      ImageIOType::Pointer dicomIO = ImageIOType::New();
      reader->SetImageIO(dicomIO);
      reader->SetFileNames(fileNames);
      reader->ForceOrthogonalDirectionOff(); // properly read CTs with gantry tilt

      //initialize image writer
      using WriterType = itk::ImageFileWriter<ImageType>;
      WriterType::Pointer writer = WriterType::New();
      std::string         outFileName;
      if (argc > 2)
      {
        outFileName = argv[2];
      }
      else
      {
        outFileName = dirName + std::string("/") + seriesIdentifier + ".nrrd";
      }
      writer->SetFileName(outFileName);
      writer->UseCompressionOn();
      writer->SetInput(reader->GetOutput());
      std::cout << "Writing: " << outFileName << std::endl;
      try
      {
        //write to image file
        writer->Update();
      }
      catch (itk::ExceptionObject & ex)
      {
        std::cout << ex << std::endl;
        continue;
      }
    }
  }
  catch (itk::ExceptionObject & ex)
  {
    std::cout << ex << std::endl;
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
