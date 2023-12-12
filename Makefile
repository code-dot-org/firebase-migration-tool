ifeq ($(shell uname),Linux)
BOOST_THREAD_LIB += -lboost_thread
endif

ifeq ($(shell uname),Darwin)
BOOST_THREAD_LIB += -lboost_thread-mt
endif

all: firebase-migration-tool search-huge-file-for


firebase-migration-tool: firebase-migration-tool.cpp Makefile munged-reader.h stock-table-names.h
	clang++ -O3 -std=c++17 -g -pthread -L /usr/local/lib -L /opt/homebrew/lib -I /opt/homebrew/include/ -o firebase-migration-tool firebase-migration-tool.cpp -lboost_system -lboost_iostreams $(BOOST_THREAD_LIB) -lmysqlcppconn

search-huge-file-for: search-huge-file-for.cpp Makefile
	clang++ -O3 -std=c++17 -g search-huge-file-for.cpp -o search-huge-file-for
