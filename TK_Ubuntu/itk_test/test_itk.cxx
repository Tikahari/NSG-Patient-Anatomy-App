#include <itkImage.h>

int
main(int, char *[])
{
  using ImageType = itk::Image<unsigned short, 3>;
  ImageType::Pointer image = ImageType::New();

  std::cout << "ITK Hello World!" << std::endl;
  std::cout << image << std::endl;

  return EXIT_SUCCESS;
}