## Geofacet: extensions for Korea


seoul_grid <-
  data.frame(
    row = c(1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6),
    col = c(6, 5, 6, 3, 4, 5, 6, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7, 8, 2, 3, 4, 6),
    code = c('DB', 'GB', 'NW', 'EP', 'JR', 'SB' ,'JN', 'MP', 'SM', 'JG', 'SD', 'DM', 'GJ',
             'GS', 'YC', 'YD', 'DJ', 'YS', 'GN', 'SP', 'GD', 'GR', 'GC', 'GA', 'SC'),
    name = c('Dobong',' Gangbuk', 'Nowon', 'Eunpyeong', 'Jongno', 'Seongbuk', 'Jungnang', 
             'Mapo', 'Seodaemun', 'Jung', 'Seongdong', 'Dongdaemun', 'Gwangjin', 'Gangseo', 'Yangcheon',
             'Yeongdeungpo', 'Dongjak', 'Yongsan', 'Gangnam', 'Songpa', 'Gangdong', 'Guro',' Geumcheon',
             'Gwanak', 'Seocho'),
    name_kr = c('도봉구', '강북구', '노원구', '은평구', '종로구' ,'성북구', '중랑구', '마포구', '서대문구',
                '중구','성동구', '동대문구', '광진구', '강서구', '양천구', '영등포구', '동작구', '용산구',
                '강남구', '송파구', '강동구', '구로구', '금천구', '관악구', '서초구'),
    # TODO: add codes
    code_sgis = c(),
    code_adm = c()
  )
  
  
## TODO: facets for districts (Seoul Metropolitan, Korea)
