/* ----------------------------------------------------------------------------

 * GTSAM Copyright 2010, Georgia Tech Research Corporation, 
 * Atlanta, Georgia 30332-0415
 * All Rights Reserved
 * Authors: Frank Dellaert, et al. (see THANKS for the full author list)

 * See LICENSE for the license information

 * -------------------------------------------------------------------------- */

/**
 * @file   testType.cpp
 * @brief  unit test for parsing a fully qualified type
 * @author Frank Dellaert
 * @date   Nov 30, 2014
 **/

#include <wrap/Qualified.h>
#include <CppUnitLite/TestHarness.h>

using namespace std;
using namespace wrap;

//******************************************************************************
TEST( Type, grammar ) {

  using classic::space_p;

  // Create type grammar that will place result in actual
  Qualified actual;
  type_grammar type_g(actual);

  // a class type with 2 namespaces
  EXPECT(parse("gtsam::internal::Point2", type_g, space_p).full);
  EXPECT(actual.name=="Point2");
  EXPECT_LONGS_EQUAL(2, actual.namespaces.size());
  EXPECT(actual.namespaces[0]=="gtsam");
  EXPECT(actual.namespaces[1]=="internal");
  EXPECT(actual.category==Qualified::CLASS);
  actual.clear();

  // a class type with 1 namespace
  EXPECT(parse("gtsam::Point2", type_g, space_p).full);
  EXPECT(actual.name=="Point2");
  EXPECT_LONGS_EQUAL(1, actual.namespaces.size());
  EXPECT(actual.namespaces[0]=="gtsam");
  EXPECT(actual.category==Qualified::CLASS);
  actual.clear();

  // a class type with no namespaces
  EXPECT(parse("Point2", type_g, space_p).full);
  EXPECT(actual.name=="Point2");
  EXPECT(actual.namespaces.empty());
  EXPECT(actual.category==Qualified::CLASS);
  actual.clear();

  // an Eigen type
  EXPECT(parse("Vector", type_g, space_p).full);
  EXPECT(actual.name=="Vector");
  EXPECT(actual.namespaces.empty());
  EXPECT(actual.category==Qualified::EIGEN);
  actual.clear();

  // a basic type
  EXPECT(parse("double", type_g, space_p).full);
  EXPECT(actual.name=="double");
  EXPECT(actual.namespaces.empty());
  EXPECT(actual.category==Qualified::BASIS);
  actual.clear();

  // void
  EXPECT(parse("void", type_g, space_p).full);
  EXPECT(actual.name=="void");
  EXPECT(actual.namespaces.empty());
  EXPECT(actual.category==Qualified::VOID);
  actual.clear();
}

//******************************************************************************
int main() {
  TestResult tr;
  return TestRegistry::runAllTests(tr);
}
//******************************************************************************
