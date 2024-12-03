{
    "header": {
        "nodesVersions": {
            "Publish": "1.3",
            "PrepareDenseScene": "3.1",
            "Texturing": "6.0",
            "FeatureMatching": "2.0",
            "Meshing": "7.0",
            "CameraInit": "9.0",
            "MeshFiltering": "3.0",
            "StructureFromMotion": "3.3",
            "ImageMatching": "2.0",
            "FeatureExtraction": "1.3"
        },
        "releaseVersion": "2023.3.0",
        "fileVersion": "1.1",
        "template": false
    },
    "graph": {
        "Texturing_1": {
            "nodeType": "Texturing",
            "position": [
                1400,
                0
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 1,
                "split": 1
            },
            "uids": {
                "0": "1dd77ccdc7321e9c61ef68edada470be87978ad0"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{Meshing_1.output}",
                "imagesFolder": "{PrepareDenseScene_1.output}",
                "inputMesh": "{MeshFiltering_1.outputMesh}",
                "inputRefMesh": "",
                "textureSide": 2048,
                "downscale": 2,
                "outputMeshFileType": "stl",
                "colorMapping": {
                    "enable": true,
                    "colorMappingFileType": "exr"
                },
                "bumpMapping": {
                    "enable": true,
                    "bumpType": "Normal",
                    "normalFileType": "exr",
                    "heightFileType": "exr"
                },
                "displacementMapping": {
                    "enable": true,
                    "displacementMappingFileType": "exr"
                },
                "unwrapMethod": "Basic",
                "useUDIM": true,
                "fillHoles": false,
                "padding": 5,
                "multiBandDownscale": 4,
                "multiBandNbContrib": {
                    "high": 1,
                    "midHigh": 5,
                    "midLow": 10,
                    "low": 0
                },
                "useScore": true,
                "bestScoreThreshold": 0.1,
                "angleHardThreshold": 90.0,
                "workingColorSpace": "sRGB",
                "outputColorSpace": "AUTO",
                "correctEV": true,
                "forceVisibleByAllVertices": false,
                "flipNormals": false,
                "visibilityRemappingMethod": "PullPush",
                "subdivisionTargetRatio": 0.8,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/",
                "outputMesh": "{cache}/{nodeType}/{uid0}/texturedMesh.{outputMeshFileTypeValue}",
                "outputMaterial": "{cache}/{nodeType}/{uid0}/texturedMesh.mtl",
                "outputTextures": "{cache}/{nodeType}/{uid0}/texture_*.exr"
            }
        },
        "Meshing_1": {
            "nodeType": "Meshing",
            "position": [
                1000,
                0
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 1,
                "split": 1
            },
            "uids": {
                "0": "382557faf1983cf38a33924555d453160eec6379"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{PrepareDenseScene_1.input}",
                "depthMapsFolder": "",
                "outputMeshFileType": "stl",
                "useBoundingBox": false,
                "boundingBox": {
                    "bboxTranslation": {
                        "x": 0.0,
                        "y": 0.0,
                        "z": 0.0
                    },
                    "bboxRotation": {
                        "x": 0.0,
                        "y": 0.0,
                        "z": 0.0
                    },
                    "bboxScale": {
                        "x": 1.0,
                        "y": 1.0,
                        "z": 1.0
                    }
                },
                "estimateSpaceFromSfM": true,
                "estimateSpaceMinObservations": 3,
                "estimateSpaceMinObservationAngle": 10.0,
                "maxInputPoints": 50000000,
                "maxPoints": 5000000,
                "maxPointsPerVoxel": 1000000,
                "minStep": 2,
                "partitioning": "singleBlock",
                "repartition": "multiResolution",
                "angleFactor": 15.0,
                "simFactor": 15.0,
                "minVis": 2,
                "pixSizeMarginInitCoef": 2.0,
                "pixSizeMarginFinalCoef": 4.0,
                "voteMarginFactor": 4.0,
                "contributeMarginFactor": 2.0,
                "simGaussianSizeInit": 10.0,
                "simGaussianSize": 10.0,
                "minAngleThreshold": 1.0,
                "refineFuse": true,
                "helperPointsGridSize": 10,
                "densify": false,
                "densifyNbFront": 1,
                "densifyNbBack": 1,
                "densifyScale": 20.0,
                "nPixelSizeBehind": 4.0,
                "fullWeight": 1.0,
                "voteFilteringForWeaklySupportedSurfaces": true,
                "addLandmarksToTheDensePointCloud": false,
                "invertTetrahedronBasedOnNeighborsNbIterations": 10,
                "minSolidAngleRatio": 0.2,
                "nbSolidAngleFilteringIterations": 2,
                "colorizeOutput": false,
                "addMaskHelperPoints": false,
                "maskHelperPointsWeight": 1.0,
                "maskBorderSize": 4,
                "maxNbConnectedHelperPoints": 50,
                "saveRawDensePointCloud": false,
                "exportDebugTetrahedralization": false,
                "seed": 0,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "outputMesh": "{cache}/{nodeType}/{uid0}/mesh.{outputMeshFileTypeValue}",
                "output": "{cache}/{nodeType}/{uid0}/densePointCloud.abc"
            }
        },
        "ImageMatching_1": {
            "nodeType": "ImageMatching",
            "position": [
                400,
                0
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 24,
                "split": 1
            },
            "uids": {
                "0": "b692454322523a1a21315c9b5c41575ee643ffff"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{FeatureExtraction_1.input}",
                "featuresFolders": [
                    "{FeatureExtraction_1.output}"
                ],
                "method": "SequentialAndVocabularyTree",
                "tree": "${ALICEVISION_VOCTREE}",
                "weights": "",
                "minNbImages": 200,
                "maxDescriptors": 500,
                "nbMatches": 40,
                "nbNeighbors": 5,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/imageMatches.txt"
            }
        },
        "FeatureExtraction_1": {
            "nodeType": "FeatureExtraction",
            "position": [
                200,
                0
            ],
            "parallelization": {
                "blockSize": 40,
                "size": 24,
                "split": 1
            },
            "uids": {
                "0": "7121b82bc817758e445174f7240cc5a11c88c641"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{CameraInit_1.output}",
                "masksFolder": "",
                "maskExtension": "png",
                "maskInvert": false,
                "describerTypes": [
                    "dspsift",
                    "sift"
                ],
                "describerPreset": "medium",
                "maxNbFeatures": 0,
                "describerQuality": "medium",
                "contrastFiltering": "GridSort",
                "relativePeakThreshold": 0.01,
                "gridFiltering": true,
                "workingColorSpace": "sRGB",
                "forceCpuExtraction": true,
                "maxThreads": 0,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/"
            }
        },
        "StructureFromMotion_1": {
            "nodeType": "StructureFromMotion",
            "position": [
                800,
                0
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 24,
                "split": 1
            },
            "uids": {
                "0": "034b3ca07cebe5a8942532f7a0d431118ac9e8b3"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{FeatureMatching_1.input}",
                "featuresFolders": "{FeatureMatching_1.featuresFolders}",
                "matchesFolders": [
                    "{FeatureMatching_1.output}"
                ],
                "describerTypes": "{FeatureMatching_1.describerTypes}",
                "localizerEstimator": "acransac",
                "observationConstraint": "Scale",
                "localizerEstimatorMaxIterations": 4096,
                "localizerEstimatorError": 0.0,
                "lockScenePreviouslyReconstructed": false,
                "useLocalBA": true,
                "localBAGraphDistance": 1,
                "nbFirstUnstableCameras": 30,
                "maxImagesPerGroup": 30,
                "bundleAdjustmentMaxOutliers": 50,
                "maxNumberOfMatches": 0,
                "minNumberOfMatches": 0,
                "minInputTrackLength": 2,
                "minNumberOfObservationsForTriangulation": 2,
                "minAngleForTriangulation": 3.0,
                "minAngleForLandmark": 2.0,
                "maxReprojectionError": 4.0,
                "minAngleInitialPair": 5.0,
                "maxAngleInitialPair": 40.0,
                "useOnlyMatchesFromInputFolder": false,
                "useRigConstraint": true,
                "rigMinNbCamerasForCalibration": 20,
                "lockAllIntrinsics": false,
                "minNbCamerasToRefinePrincipalPoint": 3,
                "filterTrackForks": false,
                "computeStructureColor": true,
                "useAutoTransform": true,
                "initialPairA": "",
                "initialPairB": "",
                "interFileExtension": ".abc",
                "logIntermediateSteps": false,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/sfm.abc",
                "outputViewsAndPoses": "{cache}/{nodeType}/{uid0}/cameras.sfm",
                "extraInfoFolder": "{cache}/{nodeType}/{uid0}/"
            }
        },
        "CameraInit_1": {
            "nodeType": "CameraInit",
            "position": [
                0,
                0
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 24,
                "split": 1
            },
            "uids": {
                "0": "a79414766982c8b8e7fcd9c0798d56f5e7d59ca1"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "viewpoints": [
                    {
                        "viewId": 33246110,
                        "poseId": 33246110,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132944.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:46\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:46\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:46\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"677\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"506316\", \"Exif:SubsecTimeDigitized\": \"506316\", \"Exif:SubsecTimeOriginal\": \"506316\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 44\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 55093010,
                        "poseId": 55093010,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132838.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:40\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:40\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:40\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"422\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"277952\", \"Exif:SubsecTimeDigitized\": \"277952\", \"Exif:SubsecTimeOriginal\": \"277952\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 38\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 95409160,
                        "poseId": 95409160,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132828.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:29\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:29\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:29\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"386\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"669677\", \"Exif:SubsecTimeDigitized\": \"669677\", \"Exif:SubsecTimeOriginal\": \"669677\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 28\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 390434206,
                        "poseId": 390434206,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132948.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:50\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:50\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:50\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"409\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"800742\", \"Exif:SubsecTimeDigitized\": \"800742\", \"Exif:SubsecTimeOriginal\": \"800742\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 48\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 402467170,
                        "poseId": 402467170,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132957.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:59\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:59\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:59\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"503\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"360465\", \"Exif:SubsecTimeDigitized\": \"360465\", \"Exif:SubsecTimeOriginal\": \"360465\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 57\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 509571832,
                        "poseId": 509571832,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132850.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:51\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:51\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:51\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"657\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"658721\", \"Exif:SubsecTimeDigitized\": \"658721\", \"Exif:SubsecTimeOriginal\": \"658721\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 50\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 540542202,
                        "poseId": 540542202,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132845.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:46\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:46\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:46\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"374\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"396100\", \"Exif:SubsecTimeDigitized\": \"396100\", \"Exif:SubsecTimeOriginal\": \"396100\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 45\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 611925949,
                        "poseId": 611925949,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132933.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:35\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:35\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:35\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"342\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"684079\", \"Exif:SubsecTimeDigitized\": \"684079\", \"Exif:SubsecTimeOriginal\": \"684079\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 33\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 643663070,
                        "poseId": 643663070,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_133004.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:30:06\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:30:06\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:30:06\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"270\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"900223\", \"Exif:SubsecTimeDigitized\": \"900223\", \"Exif:SubsecTimeOriginal\": \"900223\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 30, 4\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 767432906,
                        "poseId": 767432906,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132856.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:58\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:58\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:58\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"422\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"011664\", \"Exif:SubsecTimeDigitized\": \"011664\", \"Exif:SubsecTimeOriginal\": \"011664\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 56\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1109719737,
                        "poseId": 1109719737,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132920.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:22\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:22\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:22\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"434\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"322179\", \"Exif:SubsecTimeDigitized\": \"322179\", \"Exif:SubsecTimeOriginal\": \"322179\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 20\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1184922548,
                        "poseId": 1184922548,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132816.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:19\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:19\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:19\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"342\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"109705\", \"Exif:SubsecTimeDigitized\": \"109705\", \"Exif:SubsecTimeOriginal\": \"109705\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 16\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1361565489,
                        "poseId": 1361565489,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132926.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:28\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:28\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:28\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"342\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"679498\", \"Exif:SubsecTimeDigitized\": \"679498\", \"Exif:SubsecTimeOriginal\": \"679498\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 26\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1490217469,
                        "poseId": 1490217469,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_133013.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:30:15\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:30:15\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:30:15\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"434\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"306913\", \"Exif:SubsecTimeDigitized\": \"306913\", \"Exif:SubsecTimeOriginal\": \"306913\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 30, 13\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1520274056,
                        "poseId": 1520274056,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_133021.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:30:23\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:30:23\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:30:23\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"534\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"927040\", \"Exif:SubsecTimeDigitized\": \"927040\", \"Exif:SubsecTimeOriginal\": \"927040\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 30, 21\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1527821076,
                        "poseId": 1527821076,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132834.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:36\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:36\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:36\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"409\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"541308\", \"Exif:SubsecTimeDigitized\": \"541308\", \"Exif:SubsecTimeOriginal\": \"541308\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 34\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1563175818,
                        "poseId": 1563175818,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132953.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:55\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:55\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:55\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"409\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"451572\", \"Exif:SubsecTimeDigitized\": \"451572\", \"Exif:SubsecTimeOriginal\": \"451572\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 53\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1606518149,
                        "poseId": 1606518149,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132902.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:05\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:05\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:05\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"374\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"063779\", \"Exif:SubsecTimeDigitized\": \"063779\", \"Exif:SubsecTimeOriginal\": \"063779\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 2\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1683089224,
                        "poseId": 1683089224,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_133016.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:30:18\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:30:18\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:30:18\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"386\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"692171\", \"Exif:SubsecTimeDigitized\": \"692171\", \"Exif:SubsecTimeOriginal\": \"692171\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 30, 16\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1699153538,
                        "poseId": 1699153538,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132800.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:01\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:01\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:01\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"353\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"956362\", \"Exif:SubsecTimeDigitized\": \"956362\", \"Exif:SubsecTimeOriginal\": \"956362\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 27, 59\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1735219848,
                        "poseId": 1735219848,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_133008.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:30:10\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:30:10\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:30:10\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"386\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"984640\", \"Exif:SubsecTimeDigitized\": \"984640\", \"Exif:SubsecTimeOriginal\": \"984640\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 30, 8\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1813787863,
                        "poseId": 1813787863,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132938.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:40\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:40\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:40\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"761\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"141661\", \"Exif:SubsecTimeDigitized\": \"141661\", \"Exif:SubsecTimeOriginal\": \"141661\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 38\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 1958543869,
                        "poseId": 1958543869,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132914.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:29:16\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:29:16\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:29:16\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"374\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"152692\", \"Exif:SubsecTimeDigitized\": \"152692\", \"Exif:SubsecTimeOriginal\": \"152692\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 29, 14\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    },
                    {
                        "viewId": 2091742966,
                        "poseId": 2091742966,
                        "path": "C:/Users/Jazgalor/source/repos/projectHammer/output/received_images/IMG_20241202_132823.jpg",
                        "intrinsicId": 4053460963,
                        "rigId": -1,
                        "subPoseId": -1,
                        "metadata": "{\"AliceVision:SensorWidthEstimation\": \"3.534550\", \"DateTime\": \"2024:12:02 13:28:25\", \"Exif:ApertureValue\": \"2\", \"Exif:BrightnessValue\": \"0\", \"Exif:ColorSpace\": \"1\", \"Exif:Contrast\": \"0\", \"Exif:CustomRendered\": \"1\", \"Exif:DateTimeDigitized\": \"2024:12:02 13:28:25\", \"Exif:DateTimeOriginal\": \"2024:12:02 13:28:25\", \"Exif:ExifVersion\": \"0210\", \"Exif:ExposureBiasValue\": \"0\", \"Exif:ExposureMode\": \"0\", \"Exif:ExposureProgram\": \"2\", \"Exif:Flash\": \"0\", \"Exif:FlashPixVersion\": \"0100\", \"Exif:FocalLength\": \"3.54\", \"Exif:FocalLengthIn35mmFilm\": \"26\", \"Exif:GainControl\": \"0\", \"Exif:LightSource\": \"0\", \"Exif:MeteringMode\": \"2\", \"Exif:PhotographicSensitivity\": \"295\", \"Exif:PixelXDimension\": \"3120\", \"Exif:PixelYDimension\": \"4160\", \"Exif:Saturation\": \"0\", \"Exif:SensingMethod\": \"2\", \"Exif:Sharpness\": \"0\", \"Exif:ShutterSpeedValue\": \"5.044\", \"Exif:SubjectDistanceRange\": \"0\", \"Exif:SubsecTime\": \"534938\", \"Exif:SubsecTimeDigitized\": \"534938\", \"Exif:SubsecTimeOriginal\": \"534938\", \"Exif:WhiteBalance\": \"0\", \"Exif:YCbCrPositioning\": \"1\", \"ExposureTime\": \"0.0300041\", \"FNumber\": \"2\", \"GPS:DateStamp\": \"2024:12:02\", \"GPS:TimeStamp\": \"12, 28, 23\", \"Make\": \"HUAWEI\", \"Model\": \"SLA-L22\", \"ResolutionUnit\": \"none\", \"Software\": \"SLA-L22C432B176\", \"XResolution\": \"72\", \"YResolution\": \"72\", \"jpeg:subsampling\": \"4:2:0\", \"oiio:ColorSpace\": \"sRGB\"}"
                    }
                ],
                "intrinsics": [
                    {
                        "intrinsicId": 4053460963,
                        "initialFocalLength": 4.72,
                        "focalLength": 4.72,
                        "pixelRatio": 1.0,
                        "pixelRatioLocked": true,
                        "type": "radial3",
                        "width": 3120,
                        "height": 4160,
                        "sensorWidth": 3.53454965034716,
                        "sensorHeight": 2.65091223776037,
                        "serialNumber": "C:\\Users\\Jazgalor\\source\\repos\\projectHammer\\output\\received_images_HUAWEI_SLA-L22",
                        "principalPoint": {
                            "x": 0.0,
                            "y": 0.0
                        },
                        "initializationMode": "estimated",
                        "distortionInitializationMode": "none",
                        "distortionParams": [
                            0.0,
                            0.0,
                            0.0
                        ],
                        "undistortionOffset": {
                            "x": 0.0,
                            "y": 0.0
                        },
                        "undistortionParams": [],
                        "locked": false
                    }
                ],
                "sensorDatabase": "${ALICEVISION_SENSOR_DB}",
                "lensCorrectionProfileInfo": "${ALICEVISION_LENS_PROFILE_INFO}",
                "lensCorrectionProfileSearchIgnoreCameraModel": true,
                "defaultFieldOfView": 60.0,
                "groupCameraFallback": "folder",
                "allowedCameraModels": [
                    "pinhole",
                    "radial1",
                    "radial3",
                    "brown",
                    "fisheye4",
                    "fisheye1",
                    "3deanamorphic4",
                    "3deradial4",
                    "3declassicld"
                ],
                "rawColorInterpretation": "LibRawWhiteBalancing",
                "colorProfileDatabase": "${ALICEVISION_COLOR_PROFILE_DB}",
                "errorOnMissingColorProfile": true,
                "viewIdMethod": "metadata",
                "viewIdRegex": ".*?(\\d+)",
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/cameraInit.sfm"
            }
        },
        "MeshFiltering_1": {
            "nodeType": "MeshFiltering",
            "position": [
                1200,
                0
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 1,
                "split": 1
            },
            "uids": {
                "0": "6bf784b4fa3cb480df5fe33c9875baa81cd64855"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "inputMesh": "{Meshing_1.outputMesh}",
                "outputMeshFileType": "stl",
                "keepLargestMeshOnly": false,
                "smoothingSubset": "all",
                "smoothingBoundariesNeighbours": 0,
                "smoothingIterations": 3,
                "smoothingLambda": 1.0,
                "filteringSubset": "all",
                "filteringIterations": 1,
                "filterLargeTrianglesFactor": 60.0,
                "filterTrianglesRatio": 0.0,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "outputMesh": "{cache}/{nodeType}/{uid0}/mesh.{outputMeshFileTypeValue}"
            }
        },
        "FeatureMatching_1": {
            "nodeType": "FeatureMatching",
            "position": [
                600,
                0
            ],
            "parallelization": {
                "blockSize": 20,
                "size": 24,
                "split": 2
            },
            "uids": {
                "0": "6ebf21feddada2487813979ce2f8e52385703252"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{ImageMatching_1.input}",
                "featuresFolders": "{ImageMatching_1.featuresFolders}",
                "imagePairsList": "{ImageMatching_1.output}",
                "describerTypes": "{FeatureExtraction_1.describerTypes}",
                "photometricMatchingMethod": "ANN_L2",
                "geometricEstimator": "acransac",
                "geometricFilterType": "fundamental_matrix",
                "distanceRatio": 0.8,
                "maxIteration": 2048,
                "geometricError": 0.0,
                "knownPosesGeometricErrorMax": 5.0,
                "minRequired2DMotion": -1.0,
                "maxMatches": 0,
                "savePutativeMatches": false,
                "crossMatching": false,
                "guidedMatching": false,
                "matchFromKnownCameraPoses": false,
                "exportDebugFiles": false,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/"
            }
        },
        "PrepareDenseScene_1": {
            "nodeType": "PrepareDenseScene",
            "position": [
                1000,
                160
            ],
            "parallelization": {
                "blockSize": 40,
                "size": 24,
                "split": 1
            },
            "uids": {
                "0": "979630b66b93161231d454f139de5fdf82271fcc"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "input": "{StructureFromMotion_1.output}",
                "imagesFolders": [],
                "masksFolders": [],
                "maskExtension": "png",
                "outputFileType": "exr",
                "saveMetadata": true,
                "saveMatricesTxtFiles": false,
                "evCorrection": false,
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {
                "output": "{cache}/{nodeType}/{uid0}/",
                "undistorted": "{cache}/{nodeType}/{uid0}/<VIEW_ID>.{outputFileTypeValue}"
            }
        },
        "Publish_1": {
            "nodeType": "Publish",
            "position": [
                1255,
                195
            ],
            "parallelization": {
                "blockSize": 0,
                "size": 4,
                "split": 1
            },
            "uids": {
                "0": "fc9b38bb87738f4e7770c1a097a867bbccea180a"
            },
            "internalFolder": "{cache}/{nodeType}/{uid0}/",
            "inputs": {
                "inputFiles": [
                    "{Texturing_1.outputMesh}",
                    "{Texturing_1.outputMaterial}",
                    "{Texturing_1.outputTextures}",
                    "{Meshing_1.outputMesh}"
                ],
                "output": "C:/Users/Jazgalor/source/repos/projectHammer/output/meshroom",
                "verboseLevel": "info"
            },
            "internalInputs": {
                "invalidation": "",
                "comment": "",
                "label": "",
                "color": ""
            },
            "outputs": {}
        }
    }
}