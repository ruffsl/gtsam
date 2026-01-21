{ lib
, python3
, toPythonModule
, gtsam
}:

toPythonModule (gtsam.override {
  enablePython = true;
  inherit python3;
})
