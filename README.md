# Image_classification

## Figma에서 Export한 이미지 각 배율에 맞게 자동으로 분류하는 패키지

### Use
```
--input, -i <이미지가 위치해 있는 Directory>
--output, -o <복사한 이미지가 위치할 Directory> Default : input directory
--separator, -s <배율 앞에 붙는 구분자> Default : @
```

사용자가 지정한 inputDirectory 안에 위치한 모든 파일을 조회하고 복사한 이미지를 넣어줄 때
지정한 outputDirectory에 inputDirectory와 동일한 Directory 구조로 생성하여 각 배율에 맞는 폴더에 넣어준다.