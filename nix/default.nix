{ lib
, stdenv
, cmake
, eigen
, boost
, tbb
, mkl
, python3
, enableBoostFeatures ? true
, enableBoostSerialization ? true
, enableTBB ? true
, enableMKL ? false
, enablePython ? false
, enableUnstable ? true
, doCheck ? false
, src
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.pyparsing
    ps.pybind11-stubgen
  ]);
in
stdenv.mkDerivation {
  pname = "gtsam";
  version = "4.3-dev";

  inherit src;

  nativeBuildInputs = [
    cmake
  ] ++ lib.optionals enablePython [
    pythonEnv
    python3.pkgs.pybind11
  ];

  buildInputs = [
    eigen
  ]
    ++ lib.optional (enableBoostFeatures || enableBoostSerialization) boost
    ++ lib.optional enableTBB tbb
    ++ lib.optional enableMKL mkl;

  propagatedBuildInputs = lib.optionals enablePython [
    python3.pkgs.numpy
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    # Use system libraries
    (lib.cmakeBool "GTSAM_USE_SYSTEM_EIGEN" true)
    # Boost options
    (lib.cmakeBool "GTSAM_USE_BOOST_FEATURES" enableBoostFeatures)
    (lib.cmakeBool "GTSAM_ENABLE_BOOST_SERIALIZATION" enableBoostSerialization)
    # Optional dependencies
    (lib.cmakeBool "GTSAM_WITH_TBB" enableTBB)
    (lib.cmakeBool "GTSAM_WITH_EIGEN_MKL" enableMKL)
    # Module options
    (lib.cmakeBool "GTSAM_BUILD_UNSTABLE" enableUnstable)
    # Build options
    (lib.cmakeBool "GTSAM_BUILD_TESTS" doCheck)
    (lib.cmakeBool "GTSAM_BUILD_EXAMPLES_ALWAYS" false)
  ] ++ lib.optionals enablePython [
    (lib.cmakeBool "GTSAM_BUILD_PYTHON" true)
    (lib.cmakeBool "GTSAM_UNSTABLE_BUILD_PYTHON" enableUnstable)
    "-DGTSAM_PYTHON_VERSION=${python3.pythonVersion}"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=array-bounds";

  inherit doCheck;

  postInstall = lib.optionalString enablePython ''
    # Move Python module to standard location
    mkdir -p $out/${python3.sitePackages}
    mv $out/lib/python*/${python3.sitePackages}/* $out/${python3.sitePackages}/ || true
    mv $out/python/gtsam* $out/${python3.sitePackages}/ || true
    rm -rf $out/lib/python* $out/python || true
  '';

  meta = with lib; {
    description = "Georgia Tech Smoothing and Mapping library for robotics and vision using factor graphs";
    homepage = "https://gtsam.org";
    license = licenses.bsd3;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
