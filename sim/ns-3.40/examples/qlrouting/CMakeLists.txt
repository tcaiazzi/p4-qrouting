find_external_library(DEPENDENCY_NAME GMP
                      LIBRARY_NAME gmp)

build_example(
  NAME qlr-5-nodes
  SOURCE_FILES qlr-5-nodes.cc
  LIBRARIES_TO_LINK
    ${libcsma}
    ${libinternet}
    ${libapplications}
    ${libp4-switch}
    ${libflow-monitor}
    ${GMP_LIBRARIES}
)