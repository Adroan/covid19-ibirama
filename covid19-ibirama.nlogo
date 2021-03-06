 ;World extent for running: max-pxcor=1435 / max-pycor=2143
;FDS: Lucas, please fill with the values you use to run the simulation on your computer ->  World extent for debuging/testing: max-pxcor=717 /max-pycor=1071
extensions [ gis csv ]
globals [


  roads-dataset

  escolas-ceis-dataset
  escolas-fundamental1-dataset
  escolas-fundamental2-dataset
  escolas-medio-dataset
  escolas-universidades-dataset
  escolas-cejas-dataset
  empresas-dataset
  pracas-parques-dataset

  NUMBER_HOUSES
  NUMBER_CIVILIANS
  NUMBER_WORKERS
  NUMBER_STUDENTS
  NUMBER_PERIODS_OF_DAY ; 4 = morning, afternoon, evening, night
  STUDENTS_LIMIT
  population_pyramid_labels
  population_pyramid_values
  families_size
  families_number
  education-labels
  education-values
  mortality_labels
  mortality_values
  init med fin ;; Variables to control the turns logic flow
  elapsed-days ;FDS magic variables?
   dead

  ; constants
  LOCATION_COMPANY
  LOCATION_EDUCATION_INFANTIL
  LOCATION_EDUCATION_FUNDAMENTAL1
  LOCATION_EDUCATION_FUNDAMENTAL2
  LOCATION_EDUCATION_MEDIO
  LOCATION_EDUCATION_CEJA
  LOCATION_EDUCATION_UNIVERSIDADE
  LOCATION_PARK

  CIVILIAN_EDUCATION_INFANTIL
  CIVILIAN_EDUCATION_FUNDAMENTAL1
  CIVILIAN_EDUCATION_FUNDAMENTAL2
  CIVILIAN_EDUCATION_MEDIO
  CIVILIAN_EDUCATION_CEJA
  CIVILIAN_EDUCATION_UNIVERSIDADE
  CIVILIAN_NAO_ESTUDANTE
]

breed [ road-labels road-label ]
breed [ ponto-de-interesse-labels ponto-de-interesse-label ]
breed [ houses house]
breed [ civilians civilian]
breed [ locations location ]

civilians-own[
  homes work school park
  age types worker
  period-of-day ;; Variable to control at which turn the agent should move ( 0 = Matutino, 1 = Vespertino, 2 = Noturno )
  state days-in-state current-days
  contamined?
  testar stay-home
  how_many_i_infected
  mortality-rate
  already-spread
  currentPlaceName
  currentPlace
  anteriorPlace
  contLocal
]

houses-own[
 family_members
]

locations-own [
  location_type
  location_label
  location_capacity
]

to setup
;  show "setup is running, please wait..."
  clear-all
  ; initializing the constants
  set NUMBER_HOUSES 5515
  set NUMBER_CIVILIANS 17330
  set NUMBER_WORKERS 2462
  set NUMBER_STUDENTS 4230
  set STUDENTS_LIMIT 0
  set NUMBER_PERIODS_OF_DAY 4 ;morning, afternoon, evening, night

  set CIVILIAN_EDUCATION_INFANTIL "EI"
  set CIVILIAN_EDUCATION_FUNDAMENTAL1 "EF1"
  set CIVILIAN_EDUCATION_FUNDAMENTAL2 "EF2"
  set CIVILIAN_EDUCATION_MEDIO "EM"
  set CIVILIAN_EDUCATION_CEJA "CEJA"
  set CIVILIAN_EDUCATION_UNIVERSIDADE "UNI"
  set CIVILIAN_NAO_ESTUDANTE "NE"

  set LOCATION_COMPANY "COMP"
  set LOCATION_EDUCATION_INFANTIL "EI"
  set LOCATION_EDUCATION_FUNDAMENTAL1 "EF1"
  set LOCATION_EDUCATION_FUNDAMENTAL2 "EF2"
  set LOCATION_EDUCATION_MEDIO "EM"
  set LOCATION_EDUCATION_CEJA "CEJA"
  set LOCATION_EDUCATION_UNIVERSIDADE "UNI"
  set LOCATION_PARK "PARK"


  set init "mat" ;; Stands for matutino (morning)
  set med "vesp" ;; Stands for vespertino (afternoon)
  set fin "not"  ;; Stands for noturno (evening)
  set elapsed-days 3
  set dead 0


  initialize-population-pyramid
  initialize-families-data
  initialize-education-data
  initialize-mortality-data

  gis:load-coordinate-system (word "shapes/ruas/ruas-e-rodovias-ibirama-osm.prj")
  ; roads dataset
  set roads-dataset gis:load-dataset "shapes/ruas/ruas-e-rodovias-ibirama-osm.shp"
  ; education datasets
  set escolas-ceis-dataset gis:load-dataset "shapes/educacao/ibirama-educacao-infantil.shp"
  set escolas-fundamental1-dataset gis:load-dataset "shapes/educacao/ibirama-educacao-fundamental1.shp"
  set escolas-fundamental2-dataset gis:load-dataset "shapes/educacao/ibirama-educacao-fundamental2.shp"
  set escolas-medio-dataset gis:load-dataset "shapes/educacao/ibirama-educacao-medio.shp"
  set escolas-universidades-dataset gis:load-dataset "shapes/educacao/ibirama-educacao-universidades.shp"
  set escolas-cejas-dataset gis:load-dataset "shapes/educacao/ibirama-educacao-jovens-adultos.shp"

  ; companies
  set empresas-dataset gis:load-dataset "shapes/empresas/ibirama-empresas-todas.shp"

  ; parks and squares
  set pracas-parques-dataset gis:load-dataset "shapes/pracas-parques/ibirama-pracas-parques.shp"

  gis:set-world-envelope-ds gis:envelope-of roads-dataset
  ;gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of roads-dataset) (gis:envelope-of escolas-diurnas-dataset) (gis:envelope-of escolas-noturnas-dataset) (gis:envelope-of hospitais-clinicas-dataset) (gis:envelope-of igrejas-dataset) (gis:envelope-of mercados-dataset) (gis:envelope-of pracas-parques-dataset))

  import-drawing "images/ibirama-ruas-google-satellite-transp50.png"

  display-roads

  create-ibirama-companies
  create-ibirama-schools
  create-ibirama-parks-and-squares

  ; creation of houses and agents
  create-ibirama-houses
  create-ibirama-civilians
  assign-civilians-workplace
  assign-civilians-school

  agents-turns

  infect-people

  isolar

  if label-points-of-interest  [
      ask locations [ set label location_label]
  ]

  reset-ticks

;  show "setup is done!"
end


to display-education
  display-pontos-interesse escolas-ceis-dataset   yellow
  display-pontos-interesse escolas-fundamental1-dataset   yellow
  display-pontos-interesse escolas-fundamental2-dataset   yellow
  display-pontos-interesse escolas-medio-dataset  yellow
  display-pontos-interesse escolas-universidades-dataset   yellow
  display-pontos-interesse escolas-cejas-dataset   yellow
end

to display-companies
  display-pontos-interesse empresas-dataset  magenta

end

to display-parks-and-squares
  display-pontos-interesse pracas-parques-dataset  lime
end

to initialize-families-data
  set families_size [
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    11
  ]

  set families_number [
    617
    1457
    1467
    1094
    530
    213
    81
    34
    8
    7
    7
  ]

end

to initialize-population-pyramid
  set population_pyramid_labels [
      0
      1	
    	2 	
    	3 	
    	4 	
    	5 	
    	6 	
    	7 	
    	8 	
    	9 	
    	10 	
    	11 	
    	12 	
    	13 	
    	14 	
    	15 	
    	16 	
    	17 	
    	18 	
    	19 	
    	20 	
    	21 	
    	22 	
    	23 	
    	24 	
    	25  	
    	30	
    	35 	
    	40 	
    	45 	
    	50
    	55
    	60	
    	65
    	70
    	75
    	80
    	90
    	100
  ] ;Olhar as faixas etárias na planilha

  set population_pyramid_values [
    235
    221
    235
    247
    246
    230
    263
    236
    266
    265
    280
    290
    270
    286
    306
    306
    297
    282
    289
    270
    308
    296
    297
    313
    331
    1527
    1276
    1337
    1229
    1194
    1003
    834
    609
    516
    392
    270
    243
    35
    0
  ]
end

to initialize-education-data
  set education-labels[
    "EI"  ; Educação Infantil
    "EF1" ; Ensino Fundamental 1
    "EF2" ; Ensino Fundamental 2
    "EM"  ; Ensino Médio
    "CEJA"; Ensino de Jovens e Adultos
    "UNI" ; Universidades

  ]


 set education-values[
    449
    1567
    1078
    465
    480
    448
  ]
end

to initialize-mortality-data
  set mortality_labels []
  set mortality_values []

  let mortality_data csv:from-file mortality-rates-file

  foreach mortality_data [ mortality ->
    set mortality_labels lput (item 0 mortality) mortality_labels
    set mortality_values lput (item 1 mortality) mortality_values
  ]
end

to create-ibirama-companies
  foreach gis:feature-list-of empresas-dataset [ feature ->
     foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "triangle"
        set color magenta
        set size 1
        set location_type LOCATION_COMPANY
        set location_label gis:property-value feature "NAME"

      ]
    ]
  ]

  ; read the CSV file and initialize the number of employees for each company
  let companies locations with [location_type = LOCATION_COMPANY]
 ; show (word "created companies: " count companies )
  let companies_data csv:from-file "data/empresas/ibirama-empresas-estimativa-funcionarios.csv"
  foreach companies_data [ company ->

    ask one-of companies with [ location_label = item 0 company and location_capacity = 0] [
      ;ask locations with [ location_label = item 0 company and location_capacity = 0] [
      if location_capacity > 0 [ error "ja tem" ]
      set location_capacity item 1 company
    ]
  ]
  ;show "Companies created!"
end


to create-ibirama-schools
  foreach gis:feature-list-of escolas-ceis-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "star"
        set color yellow
        set size 1
        set location_type LOCATION_EDUCATION_INFANTIL
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]

  foreach gis:feature-list-of escolas-fundamental1-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "star"
        set color yellow
        set size 1
        set location_type LOCATION_EDUCATION_FUNDAMENTAL1
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]

  foreach gis:feature-list-of escolas-fundamental2-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "star"
        set color yellow
        set size 1
        set location_type LOCATION_EDUCATION_FUNDAMENTAL2
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]

  foreach gis:feature-list-of escolas-medio-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "star"
        set color yellow
        set size 1
        set location_type LOCATION_EDUCATION_MEDIO
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]

  foreach gis:feature-list-of escolas-cejas-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "star"
        set color yellow
        set size 1
        set location_type LOCATION_EDUCATION_CEJA
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]

  foreach gis:feature-list-of escolas-universidades-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "star"
        set color yellow
        set size 1
        set location_type LOCATION_EDUCATION_UNIVERSIDADE
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]
 ; show "Schools created!"
end

to create-ibirama-parks-and-squares
  foreach gis:feature-list-of pracas-parques-dataset [ feature ->
    foreach gis:vertex-lists-of feature [ vertex ->
      let coordinates gis:location-of item 0 vertex
      create-locations 1 [
        setxy (item 0 coordinates) (item 1 coordinates)
        set shape "tree"
        set color green
        set size 1
        set location_type LOCATION_PARK
        set location_label gis:property-value feature "NAME"
      ]
    ]
  ]
 ; show "Parks created!"
end

to create-ibirama-civilians

  let i 0;
  while [ i < (length families_number - 1)][
    let families item i families_number; families with more than 10 people are created later
    let members item i families_size

    ;show (word "creating " families " families with " members " members ")
    ask n-of families houses with [ family_members = 0 ] [
      let me who
      set family_members  members
      ;; create civilians for the family
      repeat members [
        ask patch-here [
          ifelse any? civilians-here with [age >= 16] [
            sprout-civilians 1 [
              set shape "person"
              set homes house me
              set types CIVILIAN_NAO_ESTUDANTE
              set state 1
              set period-of-day 0
              set current-days 0
              set testar 0
              set worker false
              set contamined? false
              set stay-home false
              set already-spread false
              let x random 39
              while [ item x population_pyramid_values = 0 ][
                set x random 39
              ]
              set age item x population_pyramid_labels
              let nro item x population_pyramid_values
              set nro nro - 1
              set population_pyramid_values replace-item x population_pyramid_values nro
            ]
          ][
            sprout-civilians 1 [
              set shape "person"
              set homes house me
              set types CIVILIAN_NAO_ESTUDANTE
              set state 1
              set period-of-day 0
              set current-days 0
              set testar 0
              set worker false
              set contamined? false
              set stay-home false
              set already-spread false
              let x  16 + random 23
              while [ item x population_pyramid_values = 0 ][
                set x 16 + random 23
              ]
              set age item x population_pyramid_labels
              let nro item x population_pyramid_values
              set nro nro - 1
              set population_pyramid_values replace-item x population_pyramid_values nro
            ]
          ]
        ]
      ]
    ]
    set i i + 1
  ]

  ; creating families with more than 10 people
  ; first, we create N families with 11 civilians each
  let families item ((length families_number) - 1) families_number
  let members item ((length families_size) - 1) families_size
 ; show (word "creating " families " families with " members " members ")

  ask n-of families houses with [ family_members = 0 ][
    let me who
    set family_members  members
    repeat members [
      ask patch-here [
        sprout-civilians 1 [
          set shape "person"
          set homes house me
          set types CIVILIAN_NAO_ESTUDANTE
          set state 1
          set period-of-day 0
          set current-days 0
          set testar 0
          set worker false
          set contamined? false
          set stay-home false
          set already-spread false
          let x random 39
          while [ item x population_pyramid_values = 0 ][
            set x random 39
          ]
          set age item x population_pyramid_labels
          let nro item x population_pyramid_values
          set nro nro - 1
          set population_pyramid_values replace-item x population_pyramid_values nro
        ]
      ]
    ]
  ]

  ; then, we add more civilians to these families, until NUMBER_CIVILIANS is reached
 ; show (word "adding " (NUMBER_CIVILIANS - count civilians) " more members to families with more than 10 members")
  repeat NUMBER_CIVILIANS - count civilians [
    ask one-of houses with [ family_members > 10 ][
      let me who
      set family_members  family_members + 1
      ask patch-here [
        sprout-civilians 1 [
          set shape "person"
          set homes house me
          set types CIVILIAN_NAO_ESTUDANTE
          set state 1
          set period-of-day 0
          set current-days 0
          set testar 0
          set worker false
          set contamined? false
          set stay-home false
          set already-spread false
          let x random 39
          while [ item x population_pyramid_values = 0 ][ set x random 39 ]
          set age item x population_pyramid_labels
          let nro item x population_pyramid_values
          set nro nro - 1
          set population_pyramid_values replace-item x population_pyramid_values nro
        ]
      ]
    ]
  ]

;  show "done create-ibirama-civilians"



end

to assign-civilians-school
  while [STUDENTS_LIMIT < NUMBER_STUDENTS] [
    ask one-of civilians with [types = CIVILIAN_NAO_ESTUDANTE] [
      ( ifelse

        age <= 5 [

          set types CIVILIAN_EDUCATION_INFANTIL
          let y position types education-labels
          ifelse item y education-values <= 0  [ set types CIVILIAN_NAO_ESTUDANTE  ] ; NE = Nao estudante, se for trabalhador pode sair de casa, caso contrario deve ficar
          [let tmp item y education-values
            set tmp tmp - 1
            set education-values replace-item y education-values tmp
            set school one-of locations with [ location_type = LOCATION_EDUCATION_INFANTIL ]
            set  STUDENTS_LIMIT  STUDENTS_LIMIT + 1
          ]


        ]
        age >= 6 and age <= 10 [

          set types CIVILIAN_EDUCATION_FUNDAMENTAL1
          let y position types education-labels
          ifelse  item y education-values <= 0  [ set types CIVILIAN_NAO_ESTUDANTE  ] ; NE = Nao estudante, se for trabalhador pode sair de casa, caso contrario deve ficar
          [let tmp item y education-values
            set tmp tmp - 1
            set education-values replace-item y education-values tmp
            set school one-of locations with [ location_type = LOCATION_EDUCATION_FUNDAMENTAL1 ]
            set  STUDENTS_LIMIT  STUDENTS_LIMIT + 1
          ]
        ]
        age >= 11 and age <= 14 [

          set types CIVILIAN_EDUCATION_FUNDAMENTAL2
          let y position types education-labels
          ifelse  item y education-values <= 0  [ set types CIVILIAN_NAO_ESTUDANTE  ] ; NE = Nao estudante, se for trabalhador pode sair de casa, caso contrario deve ficar
          [let tmp item y education-values
            set tmp tmp - 1
            set education-values replace-item y education-values tmp
            set school one-of locations with [ location_type = LOCATION_EDUCATION_FUNDAMENTAL2 ]
            set  STUDENTS_LIMIT  STUDENTS_LIMIT + 1
          ]
        ]
        age >= 15 [
          let k position CIVILIAN_EDUCATION_CEJA education-labels
          ifelse item k education-values <= 0 [
            if age >= 15 and age <= 17 [
              set types CIVILIAN_EDUCATION_MEDIO
              let y position types education-labels
              ifelse  item y education-values <= 0  [ set types CIVILIAN_NAO_ESTUDANTE  ] ; NE = Nao estudante, se for trabalhador pode sair de casa, caso contrario deve ficar
              [let tmp item y education-values
                set tmp tmp - 1
                set education-values replace-item y education-values tmp
                set school one-of locations with [ location_type = LOCATION_EDUCATION_MEDIO ]
                set  STUDENTS_LIMIT  STUDENTS_LIMIT + 1
              ]
            ]
          ][
            set types CIVILIAN_EDUCATION_CEJA
            let y position types education-labels
            let tmp item y education-values
            set tmp tmp - 1
            set education-values replace-item y education-values tmp
            set school one-of locations with [ location_type = LOCATION_EDUCATION_CEJA ]
            set  STUDENTS_LIMIT  STUDENTS_LIMIT + 1

          ]


      ])
      if age >= 18 and types != CIVILIAN_EDUCATION_CEJA [

        set types CIVILIAN_EDUCATION_UNIVERSIDADE
        set period-of-day 2
        let y position types education-labels
        ifelse  item y education-values <= 0  [ set types CIVILIAN_NAO_ESTUDANTE  ] ; NE = Nao estudante, se for trabalhador pode sair de casa, caso contrario deve ficar
        [let tmp item y education-values
          set tmp tmp - 1
          set education-values replace-item y education-values tmp
          set school one-of locations with [ location_type = LOCATION_EDUCATION_UNIVERSIDADE ]
          set  STUDENTS_LIMIT  STUDENTS_LIMIT + 1
        ]
      ]
    ]
  ]

;  show (word "Educação Infantil: " count civilians with [ types = CIVILIAN_EDUCATION_INFANTIL] " alunos")
;  show (word "Ensino Fundamental 1: " count civilians with [ types = CIVILIAN_EDUCATION_FUNDAMENTAL1] " alunos")
;  show (word "Ensino Fundamental 2: " count civilians with [ types = CIVILIAN_EDUCATION_FUNDAMENTAL2] " alunos")
;  show (word "Ensino Médio: " count civilians with [ types = CIVILIAN_EDUCATION_MEDIO] " alunos")
;  show (word "CEJA: " count civilians with [ types = CIVILIAN_EDUCATION_CEJA] " alunos")
;  show (word "Universidade: " count civilians with [ types = CIVILIAN_EDUCATION_UNIVERSIDADE] " alunos")
end

to assign-civilians-workplace
  ask n-of NUMBER_WORKERS civilians with [ age >= 10 ]  [
    set worker true
    set work one-of locations with [ location_type = LOCATION_COMPANY and location_capacity > 0 ]
    ask work [set location_capacity location_capacity - 1 ]
  ]

end

to infect-people
 ; show (word "infecting " infected-students" students...")

  ask n-of infected-students civilians with [ types != CIVILIAN_NAO_ESTUDANTE and not worker][ ; just students
    set state 2
    let b (max-exposed - min-exposed) + 1
    set days-in-state min-exposed + random b
  ]
;  show "infection of students is done"

;  show (word "infecting " infected-workers" workers...")
  ask n-of infected-workers civilians with [ worker = true and types = CIVILIAN_NAO_ESTUDANTE]   [ ; just workers
    set state 2
    let b (max-exposed - min-exposed) + 1
    set days-in-state min-exposed + random b
  ]
 ; show "infection of workers is done"

 ; show (word "infecting " infected-workers" workers that are also students...")
  ask n-of infected-workers-that-study civilians with [ worker = true and  types != CIVILIAN_NAO_ESTUDANTE ]   [ ; workers that study
    set state 2
    let b (max-exposed - min-exposed) + 1
    set days-in-state min-exposed + random b
  ]
 ; show "infection of workers that are also students is done"

 ; show (word "infecting " infected-workers" non-students and unemployed people...")
  ask n-of infected-nonstudents-unemployed civilians with [ worker = false and types = CIVILIAN_NAO_ESTUDANTE]   [
    set state 2
    let b (max-exposed - min-exposed) + 1
    set days-in-state min-exposed + random b
  ]
 ; show "infection of non-students and unemployed people is done"
end


to create-ibirama-houses
  display-roads-in-patches ; first we need to identify the patches that are roads
  ask n-of NUMBER_HOUSES patches with [pcolor = cyan and count neighbors with [pcolor != cyan] > 0] [
     ; create a home in a neighbor patch that is not a road (whose color is not cyan)
    ask n-of 1 neighbors with [ pcolor != cyan] [
      sprout-houses 1 [
        set shape "house"
        set family_members 0

      ]
    ]
  ]
  ask patches [ set pcolor black ]
 ; show "done create-ibirama-houses"
end

to display-roads
  ask road-labels [ die ]
  gis:set-drawing-color blue
  gis:draw roads-dataset 1
  if label-roads
  [
    label-dataset roads-dataset
  ]
end



;to display-pontos-interesse
;  ask ponto-de-interesse-labels [ die ]
;  gis:set-drawing-color yellow
;  gis:draw escolas-diurnas-dataset 1
;  if label-roads
;  [
;    label-dataset escolas-diurnas-dataset
;  ]
;end

to display-pontos-interesse [the-dataset  the-color]
  gis:set-drawing-color the-color
  gis:draw the-dataset 1
  if label-points-of-interest
  [
    label-dataset the-dataset
  ]
end

to label-dataset [the-dataset]
  foreach gis:feature-list-of the-dataset [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      ; centroid will be an empty list if it lies outside the bounds
      ; of the current NetLogo world, as defined by our current GIS
      ; coordinate transformation
      if not empty? centroid
      [ create-road-labels 1
          [ set xcor item 0 centroid
            set ycor item 1 centroid
            set size 0
            set label gis:property-value vector-feature "NAME"
        set hidden? false
          ]
      ]
    ]
end

; Using gis:intersecting to find the set of patches that intersects
; a given vector feature (in this case, a road).
to display-roads-in-patches
  ask patches [ set pcolor black ]
  ask patches gis:intersecting roads-dataset
  [ set pcolor cyan ]
end


; This is an example of how to select a subset of a raster dataset
; whose size and shape matches the dimensions of the NetLogo world.
; It doesn't actually draw anything; it just modifies the coordinate
; transformation to line up patch boundaries with raster cell
; boundaries. You need to call one of the other commands after calling
; this one to see its effect.
to match-cells-to-patches
  gis:set-world-envelope gis:raster-world-envelope roads-dataset 0 0
  clear-drawing
  clear-turtles
end

to agents-turns
  let cont count civilians with [ types = CIVILIAN_EDUCATION_FUNDAMENTAL1 ]
  set cont cont / 2
   ask n-of cont civilians with [ types = CIVILIAN_EDUCATION_FUNDAMENTAL1 ] [
    set period-of-day 1
  ]

  set cont count civilians with [ types = CIVILIAN_EDUCATION_FUNDAMENTAL2 ]
  set cont cont / 2
   ask n-of cont civilians with [ types = CIVILIAN_EDUCATION_FUNDAMENTAL2 ] [
    set period-of-day 1
  ]

  set cont count civilians with [ types = CIVILIAN_EDUCATION_MEDIO ]
  set cont cont / 3
  ask n-of cont civilians with [ types = CIVILIAN_EDUCATION_MEDIO ] [
    set period-of-day 1
  ]
  ask n-of cont civilians with [ types = CIVILIAN_EDUCATION_MEDIO and period-of-day != 1 ] [
    set period-of-day 2
  ]

  set cont count civilians with [ types = CIVILIAN_EDUCATION_CEJA ]
  set cont cont / 3
  ask n-of cont civilians with [ types = CIVILIAN_EDUCATION_CEJA ] [
    set period-of-day 1
  ]
  ask n-of cont civilians with [ types = CIVILIAN_EDUCATION_CEJA and period-of-day != 1 ] [
    set period-of-day 2
  ]

end

to turns

  if ticks != elapsed-days [
    ;Show "---------------------------------------------------"
   ; show word "Turno atual que se passou é: " init
    let aux init
    set init med
    set med fin
    set fin aux
   ; show word "Próximo turno será: " init

  ]

  if ticks >= elapsed-days [
    set elapsed-days elapsed-days + 4
   ; show "madrugada!"

  ]
  ;; Resembles something like a bubbleSort for a simple logic to be used
end

to go

  move
  human-state
  turns
  show ticks
  ask civilians with [stay-home = false ]  [
    if (xcor = item 0 currentPlace) and (ycor = item 1 currentPlace)  [
      set contLocal contLocal + 1
      if worker = true or types != CIVILIAN_NAO_ESTUDANTE [
        ifelse worker = true and types != CIVILIAN_NAO_ESTUDANTE and period-of-day = 2 [
          ifelse ( [xcor] of work != [xcor] of school ) and ( [ycor] of work != [ycor] of school ) [
            if contLocal >= 3 [ show "Agente se movendo errado!" ]
          ][ if contLocal > 3 [ show "Agente se movendo errado!" ] ]
        ][
          if contLocal >= 3 [ show "Agente se movendo errado!" ]
        ]
      ]
    ]
  ]

  tick
end

to move
  ;ask walkers[ ;FDS why not 'ask'?
  foreach sort civilians [ the-turtle ->  ;; EI EF1 EF2 EM CEJA UNI ;FDS why 'sort'?
    ask the-turtle [                      ;; 'period-of-day' represents the variable to control at which turn the agent should move ( 0 = Matutino, 1 = Vespertino, 2 = Noturno )
      ifelse stay-home = true [][
      ifelse ticks >= elapsed-days [      ;; EF1 e EF2 sao dividos em 0 e 1, CEJA e EM sao dividos em 0;1;2, UNI sempre será 2, EI é 0 mas deve permanecer no turno vespertino
         if period-of-day = 2 and types != CIVILIAN_NAO_ESTUDANTE [ if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ] move-backhome ]
          set currentPlace [ 0 0 ]
          set contLocal 0
          set already-spread false
      ][
      if init = "mat" [
            if (period-of-day = 0 and types != CIVILIAN_NAO_ESTUDANTE) [  if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ] move-to-school  ]
            if (worker = true and period-of-day != 0) [if worker = false [ show "Agente se movendo errado" ] move-to-work ]
            if (worker = true and period-of-day = 0 and types = CIVILIAN_NAO_ESTUDANTE) [ if worker = false [ show "Agente se movendo errado" ] move-to-work]


            set anteriorPlace list xcor ycor
            set currentPlace anteriorPlace

          ]
          if init = "vesp" [
            if ( period-of-day = 0 and worker = false and types != CIVILIAN_EDUCATION_INFANTIL and types != CIVILIAN_NAO_ESTUDANTE) [ if worker = true or types = CIVILIAN_EDUCATION_INFANTIL [ show "Agente se movendo errado" ] move-backhome ] ;; <- Rotina da escola pra casa
            if ( period-of-day = 0 and worker = true and types != CIVILIAN_NAO_ESTUDANTE) [if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ]  move-to-work] ;; <- Rotina da escola pro trabalho

            if (period-of-day = 1 and worker = false and types != CIVILIAN_NAO_ESTUDANTE) [if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ]   move-to-school  ] ;; <- Rotina de casa para a escola

            if (period-of-day = 1 and worker = true  and types != CIVILIAN_NAO_ESTUDANTE) [ if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ]  move-to-school  ] ;; <- Rotina do trabalho para a escola

            set currentPlace anteriorPlace
            set anteriorPlace list xcor ycor
          ]
          if init = "not" [
            if period-of-day = 1 [ move-backhome ]
            if (period-of-day = 0 and worker = true) or (types = CIVILIAN_EDUCATION_INFANTIL) [ move-backhome]
            if (types = CIVILIAN_NAO_ESTUDANTE) and (worker = true) [ move-backhome] ;;Somar as 3 rotinas de backhome para dar valor total

            if period-of-day = 2 and worker = false and types != CIVILIAN_NAO_ESTUDANTE [ if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ] move-to-school  ] ;; <- Rotina de casa pra escola
            if period-of-day = 2 and worker = true  and types != CIVILIAN_NAO_ESTUDANTE [if types = CIVILIAN_NAO_ESTUDANTE [ show "Agente se movendo errado" ]  move-to-school  ] ;; <- Rotina do trabalho pra escola

            set already-spread false

            set currentPlace anteriorPlace
            set anteriorPlace list xcor ycor
          ]
        ]
      ]
    ]
  ]
  ;]

end

to isolar

  let try 0
   set try workers-isolation-fraction * NUMBER_WORKERS
 ; show try
    ask n-of try civilians with [ worker = true ][
      set stay-home true

    ]


    set try students-isolation-fraction * NUMBER_STUDENTS
 ; show try
    ask n-of try civilians with [ types != CIVILIAN_NAO_ESTUDANTE ][
      set stay-home true
    ]



end

to move-to-school
  move-to school
  set currentPlaceName [location_label] of school
  set testar testar + 1
end

to move-to-work
  move-to work
  set currentPlaceName [location_label] of work
  set testar testar + 1
end

to move-to-park
  move-to park
  set currentPlaceName [location_label] of park
  set testar testar + 1
end

to move-backhome
  move-to homes
  set currentPlaceName "at home"
  set testar testar + 1
end

to human-state
  ; ask walkers[
  foreach sort civilians [ the-turtle ->
    ask the-turtle [

      if state != 1 [
        if ticks >= elapsed-days [
          set current-days current-days + 1
        ]
      ]

      if state = 1 [
        ifelse ticks >= elapsed-days [][

          if already-spread = false [
            let lista  sort  other civilians-here
            while [ length lista != 0 ] [
              let prim first lista
              if contamined? = false [
                if (xcor = [xcor] of prim) and (ycor = [ycor] of prim)[
                  if [state] of prim = 3 [
                    let try random-float 1
                    if try <= transmission-probability [
                      set contamined? true
                      set color orange
                      set state 2
                      let b (max-exposed - min-exposed) + 1
                      set days-in-state min-exposed + random b

                      ask prim [ set how_many_i_infected how_many_i_infected + 1 ]
                    ]
                  ]
                ]
              ]
              set lista but-first lista
            ]
            if  worker = true  [
              if (types = CIVILIAN_NAO_ESTUDANTE) or (types != CIVILIAN_NAO_ESTUDANTE and period-of-day = 2)  [ set already-spread true ] ]
          ]
        ]
      ]

      if state = 2 [
        if current-days >= days-in-state [
          set color red
          set state 3
          let b (max-infected - min-infected) + 1
          set days-in-state min-infected + random b
          set mortality-rate ( find-mortality-rate age) / days-in-state
          ; show (word "age " age " mortality rate " find-mortality-rate age); for debugging
          set current-days 0
        ]
      ]
      if state = 3 [
        ; the agent can die in any of the days it is infected
        let try random-float 1
        if try < mortality-rate [
          set dead dead + 1
          die
        ]
        if current-days > days-in-state [
          set current-days 0
          set state 4
          set color blue
        ]
      ]
    ]
  ]
  ;; Susceptible(White); Exposed(Orange); Infected(Red); Recovered(Blue)
  ;; Color patterns for agents following a SEIR model
  ;]


end

to-report find-mortality-rate [ civilian_age ]
  ; given a particular range (min_value, max_value), we assume that
  ; the list 'mortality_labels' contains just the 'min_values', and therefore
  let i 0
  repeat length mortality_labels [
    let mort_label item i mortality_labels
    if civilian_age <  mort_label [
      report item (i - 1) mortality_values
    ]
    set i i + 1
  ]
  ; the last mortality_value is assumed to be the mortality rate
  ; for ages >= its 'min_value'
  report item (i - 1) mortality_values
end

; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
333
10
1777
2163
-1
-1
1.0
1
8
1
1
1
0
0
0
1
0
1435
0
2143
0
0
1
periods-of-day
30.0

BUTTON
147
649
212
682
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1823
1164
1964
1197
NIL
display-roads-in-patches
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1821
1046
1929
1079
NIL
clear-drawing
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1822
1085
1929
1118
label-roads
label-roads
1
1
-1000

SWITCH
1824
1206
1993
1239
label-points-of-interest
label-points-of-interest
1
1
-1000

PLOT
1827
1374
2176
1600
families
members
number of families
1.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [family_members] of houses with [ family_members > 0 ]"

TEXTBOX
11
561
191
595
Social isolation parameters:
14
0.0
1

BUTTON
225
649
288
682
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
2
699
330
943
COVID-19 Daily Monitoring
Days
Number of people
1.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Susceptible" 1.0 0 -13840069 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ state = 1 ]]"
"Exposed" 1.0 0 -955883 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ state = 2 ]]"
"Infected" 1.0 0 -2674135 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ state = 3 ]]"
"Recovered" 1.0 0 -13791810 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with[ state = 4]]"
"Population" 1.0 0 -16777216 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians]"
"Deaths" 1.0 0 -10402772 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [ plot dead ]"

BUTTON
1826
1324
1978
1357
NIL
display-parks-and-squares
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1825
1287
1978
1320
NIL
display-companies
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1825
1247
1979
1280
NIL
display-education
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1823
1125
1932
1158
NIL
display-roads
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
150
582
281
642
workers-isolation-fraction
0.1
1
0
Number

INPUTBOX
9
582
145
642
students-isolation-fraction
0.0
1
0
Number

INPUTBOX
9
412
114
472
infected-students
0.0
1
0
Number

INPUTBOX
14
150
136
210
transmission-probability
0.3435
1
0
Number

TEXTBOX
1824
1020
1974
1038
Additional controls
12
104.0
1

TEXTBOX
16
12
252
46
COVID-19 Parameters (SEIR model)
14
0.0
1

INPUTBOX
15
64
96
124
min-exposed
5.0
1
0
Number

TEXTBOX
18
44
206
72
EXPOSED compartment duration:
11
0.0
1

INPUTBOX
102
65
182
125
max-exposed
6.0
1
0
Number

TEXTBOX
14
225
196
253
INFECTED compartment duration:
11
0.0
1

INPUTBOX
11
242
95
302
min-infected
8.0
1
0
Number

INPUTBOX
100
242
182
302
max-infected
8.0
1
0
Number

TEXTBOX
15
136
165
154
Transmission probability:
11
0.0
1

TEXTBOX
13
397
197
425
Number of initially infected agents:
11
0.0
1

TEXTBOX
8
681
158
699
Simulation monitoring
14
0.0
1

MONITOR
192
999
278
1044
Elapsed days
ticks / NUMBER_PERIODS_OF_DAY
0
1
11

MONITOR
10
951
84
996
Susceptibles
count civilians with [ state = 1 ]
0
1
11

MONITOR
89
951
165
996
Exposed
count civilians with [ state = 2 ]
0
1
11

MONITOR
169
951
244
996
Infected
count civilians with [ state = 3 ]
0
1
11

MONITOR
56
1000
126
1045
Deaths
dead
0
1
11

MONITOR
248
951
320
996
Recovered
count civilians with [ state = 4 ]
0
1
11

MONITOR
1989
1316
2126
1361
R0
mean [how_many_i_infected] of civilians with [state > 1]
17
1
11

TEXTBOX
12
310
162
328
Mortality:
11
0.0
1

INPUTBOX
9
327
282
387
mortality-rates-file
data/disease/mortality-rates-china.csv
1
0
String

INPUTBOX
121
413
220
473
infected-workers
1.0
1
0
Number

PLOT
1
1049
326
1278
COVID-19 Workers Daily Monitoring
Days
Number of people
1.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Population" 1.0 0 -16777216 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ worker = true ]]"
"Susceptible" 1.0 0 -13840069 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ worker = true and state = 1 ]]"
"Exposed" 1.0 0 -955883 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ worker = true and state = 2 ]]"
"Infected" 1.0 0 -2674135 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ worker = true and state = 3 ]]"
"Recovered" 1.0 0 -13791810 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ worker = true and state = 4 ]]"

PLOT
2
1286
325
1511
COVID-19 Students Daily Monitoring
Days
Number of people
1.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Population" 1.0 0 -16777216 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types != CIVILIAN_NAO_ESTUDANTE ]]"
"Susceptible" 1.0 0 -13840069 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 1]]"
"Exposed" 1.0 0 -955883 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 2 ]]"
"Infected" 1.0 0 -2674135 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 3]]"
"Recovered" 1.0 0 -13791810 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 4]]"

PLOT
2
1535
324
1773
COVID-19 Non-students and Unemployed Daily Monitoring
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Population" 1.0 0 -16777216 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false]]"
"Susceptible" 1.0 0 -13840069 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 1]]"
"Exposed" 1.0 0 -955883 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 2]]"
"Infected" 1.0 0 -2674135 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 3]]"
"Recovered" 1.0 0 -13791810 true "" "if (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [plot count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 4]]"

INPUTBOX
9
480
150
540
infected-workers-that-study
0.0
1
0
Number

INPUTBOX
155
479
327
539
infected-nonstudents-unemployed
0.0
1
0
Number

PLOT
1823
1613
2181
1833
infections per infected agent
number of infections
number of agents
0.0
100.0
0.0
10.0
true
false
"" "set-plot-x-range 1 (max [how_many_i_infected] of civilians) + 1\n;set-histogram-num-bars 10"
PENS
"default" 1.0 1 -16777216 true "" "histogram [how_many_i_infected] of civilians with [ state >= 3  and how_many_i_infected > 0] "

@#$#@#$#@
## WHAT IS IT?

This model was built to test and demonstrate the functionality of the GIS NetLogo extension.

## HOW IT WORKS

This model loads four different GIS datasets: a point file of world cities, a polyline file of world rivers, a polygon file of countries, and a raster file of surface elevation. It provides a collection of different ways to display and query the data, to demonstrate the capabilities of the GIS extension.

## HOW TO USE IT

Select a map projection from the projection menu, then click the setup button. You can then click on any of the other buttons to display data. See the code tab for specific information about how the different buttons work.

## THINGS TO TRY

Most of the commands in the Code tab can be easily modified to display slightly different information. For example, you could modify `display-cities` to label cities with their population instead of their name. Or you could modify `highlight-large-cities` to highlight small cities instead, by replacing `gis:find-greater-than` with `gis:find-less-than`.

## EXTENDING THE MODEL

This model doesn't do anything particularly interesting, but you can easily copy some of the code from the Code tab into a new model that uses your own data, or does something interesting with the included data. See the other GIS code example, GIS Gradient Example, for an example of this technique.

## RELATED MODELS

GIS Gradient Example provides another example of how to use the GIS extension.

<!-- 2008 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
setup
display-cities
display-countries
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="WorkersExperiment1(0;10)" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="360"/>
    <metric>count civilians</metric>
    <metric>count civilians with [ state = 1 ]</metric>
    <metric>count civilians with [ state = 2 ]</metric>
    <metric>count civilians with [ state = 3 ]</metric>
    <metric>count civilians with [ state = 4 ]</metric>
    <metric>dead</metric>
    <metric>count civilians with [ worker = true ]</metric>
    <metric>count civilians with [ worker = true and state = 1 ]</metric>
    <metric>count civilians with [ worker = true and state = 2 ]</metric>
    <metric>count civilians with [ worker = true and state = 3 ]</metric>
    <metric>count civilians with [ worker = true and state = 4 ]</metric>
    <metric>count civilians with [ types != CIVILIAN_NAO_ESTUDANTE ]</metric>
    <metric>count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 1]</metric>
    <metric>count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 2]</metric>
    <metric>count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 3]</metric>
    <metric>count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 4]</metric>
    <metric>count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false]</metric>
    <metric>count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 1]</metric>
    <metric>count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 2]</metric>
    <metric>count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 3]</metric>
    <metric>count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 4]</metric>
    <metric>count civilians with [ state &gt;= 3  and how_many_i_infected &gt; 0]</metric>
    <enumeratedValueSet variable="infected-nonstudents-unemployed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmission-probability">
      <value value="0.3435"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-workers-that-study">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students-isolation-fraction">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-exposed">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="label-roads">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality-rates-file">
      <value value="&quot;data/disease/mortality-rates-china.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-infected">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="label-points-of-interest">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="workers-isolation-fraction">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-exposed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-infected">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-workers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-students">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="WorkersExperiment-Dayly-Monitoring(0;10)" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="360"/>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [ticks / NUMBER_PERIODS_OF_DAY] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ state = 1 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ state = 2 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ state = 3 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ state = 4 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [dead] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ worker = true ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ worker = true and state = 1 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ worker = true and state = 2 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ worker = true and state = 3 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ worker = true and state = 4 ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types != CIVILIAN_NAO_ESTUDANTE ]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 1]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 2]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 3]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types != CIVILIAN_NAO_ESTUDANTE and state = 4]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 1]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 2]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 3]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ types = CIVILIAN_NAO_ESTUDANTE and worker = false and state = 4]] [""]</metric>
    <metric>ifelse-value (ticks mod NUMBER_PERIODS_OF_DAY) = 0 [count civilians with [ state &gt;= 3  and how_many_i_infected &gt; 0]] [""]</metric>
    <enumeratedValueSet variable="students-isolation-fraction">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="workers-isolation-fraction">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-students">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-workers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-workers-that-study">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infected-nonstudents-unemployed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmission-probability">
      <value value="0.3435"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-exposed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-exposed">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-infected">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-infected">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortality-rates-file">
      <value value="&quot;data/disease/mortality-rates-china.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="label-points-of-interest">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="label-roads">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
