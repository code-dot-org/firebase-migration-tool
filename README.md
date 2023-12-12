# Firebase Migration Tool

As part of migrating Applab to use MySQL instead of Firebase, we have to migrate existing data. We'll be migrating a terabyte of firebase JSON to MySQL (see: https://github.com/code-dot-org/code-dot-org/issues/55084). Initial versions of this tool were written in Ruby (and Javascript), but performance was so slow it would have taken many days to migrate data, possibly more than a week. The current version of the tool is written in C++ using the RapidJSON (https://rapidjson.org/) library, conveniently the same JSON parser as MySQL uses internally.

The tool:
1. Does a streaming "SAX-like" parse because all the JSON will not fit into memory.
2. Supports uploading data as a row-per-student-record, row-per-student-table or row-per-student-project format.
3. Detects stock datasets and optionally deplicates them.
4. Uses a configurable number of background threads for uploading data to MySQL, unblocking the main thread for JSON parsing (this is the bottleneck currently).
5. Validates JSON record rows before inserting them, drops invalid rows.

# For MacOS:

## Edit mysql-connector-c++ to install jdbc.h
Need to edit the mysql-connector-c++ formula first (UGH! they don't include the jdbc bits required for an AWS RDS instance which doesn't support x plugin, used by the newer connector APIs 😥, edits are based off parallel in freebsd ports: https://cgit.freebsd.org/ports/commit/?id=adcb80f3fa92f9f25c3aa84fc4b1e1e79919acc0). 

See: https://docs.brew.sh/FAQ#can-i-edit-formulae-myself

1. export HOMEBREW_NO_INSTALL_FROM_API=1
2. `brew edit mysql-connector-c++`
3. Find this line: `system "cmake", "-S", ".", "-B", "build", "-DINSTALL_LIB_DIR=lib", *std_cmake_args`
4. Change it to: `system "cmake", "-S", ".", "-B", "build", "-DINSTALL_LIB_DIR=lib", "-DWITH_JDBC=ON", *std_cmake_args`
5. `brew reinstall --build-from-source mysql-connector-c++`
6. Verify the jdbc.h header is now installed: `ls /opt/homebrew/include/mysql/jdbc.h`
7. For docs on using the legacy jdbc.h API see: https://dev.mysql.com/doc/dev/connector-cpp/latest/jdbc_ref.html

## Install mac deps
1. `brew install rapidjson boost`


# For Linux:

## Install linux deps
1. `apt-get install clang rapidjson-dev libboost-iostreams-dev build-essential libboost-system-dev libboost-thread-dev`

## Same problem, need to build from source to get -DWITH_JDBC=ON
1. `git clone https://github.com/mysql/mysql-connector-cpp.git`
2. cd mysql-connector-cpp
3. `cmake -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DWITH_JDBC=ON .`
4. `cmake --build .`
5. `sudo cmake --build . --target install`
6. This is super annoying but I haven't figured out how to fix it with proper build args to the cmake, and this is limited use so here's the hack: `sudo mv /usr/local/lib64/libmysqlcppconn* /usr/local/lib`
7. `sudo ldconfig`


# For everyone:

You can use the `get-latest-firebase-data.sh` script to fetch the latest backup from firebase.

1. make
2. ./firebase-migration-tool lil-prod.json
