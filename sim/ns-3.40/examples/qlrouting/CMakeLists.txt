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

build_example(
        NAME qlr-5-nodes
        SOURCE_FILES qlr-5-nodes.cc
        LIBRARIES_TO_LINK
        ${libcsma}
        ${libinternet}
        ${libapplications}
        ${libp4-switch}
        ${libflow-monitor}
)
