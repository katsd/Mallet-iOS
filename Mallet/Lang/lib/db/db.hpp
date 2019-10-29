//
//  db.hpp
//  Mallet
//
//  Created by Katsu Matsuda on 2019/10/02.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

#ifndef db_h
#define db_h

#include "../../common.hpp"
#include "../../cast.hpp"

#include <string>

/*
#import <vector>
#import "common.hpp"
 */

void setAppVariable(std::string varName, std::string value);

std::string getAppVariable(int address);

void setCloudVariable(std::string varName, std::string value);

void setCloudList(std::string varName, std::vector<var> value);

void addToCloudList(std::string varName, std::string value);

std::string getCloudVariable(std::string name);

void initPersistentVariable();

#endif /* db_h */