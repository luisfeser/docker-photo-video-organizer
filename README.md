# Docker photo video organizer (and optimizer)
Is a docker image that organize photos and videos in year/month folder hierarchy
Also it convert videos into an optimized AV1 codec saving a lot of space. A video of 1G can be reduced to 100-200Mb, easyly a 80%.
The date of photo/video is obtanied from the exif data, not filesystem creation or modification.

Sample of folder structure:

    .
    |-- output
    |   |-- 2022
    |   |   |-- 06
    |   |   |   `-- IMG_20220611_161328.jpg
    |   |   |-- 08
    |   |   |   |-- IMG_20220814_123022.jpg
    |   |   |   |-- IMG_20220814_123038.jpg
    |   |   |   |-- IMG_20220814_143000.jpg
    |   |   |   `-- IMG_20220814_143022_1.jpg
    |   |   `-- 11
    |   |       |-- IMG_20221128_162849.jpg
    |   |       |-- IMG_20221128_162931.jpg
    |   |       `-- IMG_20221128_163015.jpg
    |   `-- 2024
    |       `-- 06
    |           |-- IMG_20170825_195317.jpg
    |           |-- PXL_20240607_185952040_AV1.mp4  # The optimized video
    |-- input # result is empty
    `-- videos-originales
        `-- PXL_20240607_185952040.mp4  # The original video


The contanier recive three volumes:
- input --> the folder contaning multimedia files
- output --> where the collection is organized (photos and optimized videos)
- videos_originales --> the original video file. You always can remove it if you are happy with the converting one or you can save in a big storage.

## Usage
Simply run

    docker run --rm -v /path/local/input/:/input -v /path/local/output/:/output -v /path/to-store/videos-orignales/:/videos_originales luisfeser/photo-video-organizer
