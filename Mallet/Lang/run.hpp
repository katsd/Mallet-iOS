
//
//  run.hpp
//  Mallet
//
//  Created by Katsu Matsuda on 2019/06/24.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

#ifndef run_h
#define run_h

#include "common.hpp"
#include "cast.hpp"
#include "cpp_func_manager.hpp"

#ifndef TEST
#include "./lib/db/db.hpp"
#include "./lib/ui/ui.hpp"
#endif

class Run
{
public:
    void Terminate();

    bool UpdateCloudVariable(std::string varName, std::string value);

    bool UpdateCloudList(std::string varName, std::vector<std::string> value);

    void InitRunner(std::string codeDataStr, std::map<std::string, std::string> variables);

    void InitPersistentVariables(std::map<std::string, std::string> variables);

    var RunCode(int funcID, std::vector<var> args);

    Run();

private:
    struct globalVariableInfo
    {
        int address = -1;
        bool isUI = false;
        bool isCloud = false;
        bool isPersistent = false;
        int uiID = -1;
    };

    bool terminate;

    static constexpr int pushCodeSize = 5;
    static constexpr int defaultCodeSize = 3;

    CppFuncManager cppFuncManager;

    std::map<std::string, std::string> persistentVariables;
    std::map<std::string, std::string> cloudVariables;

    std::vector<int> memorySize;
    std::vector<var> globalVariable;
    int globalVariableNum;

    std::vector<int> listMemorySize;
    std::vector<list> globalList;
    int globalListNum;

    std::map<std::string, globalVariableInfo> globalVariableData;

    std::vector<int> bytecode;

    std::vector<var> variableInitialValues;

    std::vector<int> funcStartIndexes;
    std::vector<std::vector<int>> argAddresses;

    std::vector<int> funcTypes;

    var CallCppFunc(int funcID, std::vector<var> &args);
};

#endif /* run_h */