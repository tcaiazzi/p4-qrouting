build_example(
  NAME qlr-example
  SOURCE_FILES qlr-example.cc
  LIBRARIES_TO_LINK
  ${libcsma}
  ${libinternet}
  ${libapplications}
  ${libp4-switch}
  ${libflow-monitor}
)
