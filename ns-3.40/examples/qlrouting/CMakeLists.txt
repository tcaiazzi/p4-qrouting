find_external_library(DEPENDENCY_NAME GMP
                      LIBRARY_NAME gmp)

build_example(
        NAME qlr-experiment
        SOURCE_FILES qlr-experiment.cc tracer.cc socket-utils.cc utils.cc qlr-utils.cc workload_parser.cc
        LIBRARIES_TO_LINK
        ${libpoint-to-point}
        ${libinternet}
        ${libapplications}
        ${libp4-switch}
        ${libflow-monitor}
        ${GMP_LIBRARIES}
)
