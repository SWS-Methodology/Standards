unique(vegetableOilsDataForIndUses$Country_Name)

USDA_2_SUA_country <- function(Country_Name){
  
  if(Country_Name == "Australia"){
    return(geographicAreaM49 = 36)
  }
  
  if(Country_Name == "Austria"){
    return(geographicAreaM49 = 40)
  }
  
  if(Country_Name == "Bangladesh"){                
    return(geographicAreaM49 = 50)
  }
  
  if(Country_Name == "Belgium-Luxembourg"){
    return(geographicAreaM49 = 58)
  }

  if(Country_Name == "Cote d'Ivoire"){
    return(geographicAreaM49 = 384)
  }

  if(Country_Name == "Denmark"){
    return(geographicAreaM49 = 208)
  }

  if(Country_Name == "EU-15"){
    return(geographicAreaM49 = NA) #to check
  }
  
  if(Country_Name == "European Union"){
    return(geographicAreaM49 = NA) #to check
  }
  
  if(Country_Name == "Fiji"){
    return(geographicAreaM49 = 242)
  }
  
  if(Country_Name == "France"){
    return(geographicAreaM49 = 250)
  }
  
  if(Country_Name == "German Democratic Republic"){
    return(geographicAreaM49 = NA)  # i used only Germany
  }
  
  if(Country_Name == "Germany, Federal Republic of"){
    return(geographicAreaM49 = NA) # i used only Germany
  }
  
  if(Country_Name == "Ghana"){
    return(geographicAreaM49 = 288)
  }
  
  if(Country_Name == "Hong Kong"){
    return(geographicAreaM49 = 344)
  }
  
  if(Country_Name == "India"){
    return(geographicAreaM49 = 356)
  }
  
  if(Country_Name == "Indonesia"){
    return(geographicAreaM49 = 360)
  }
  
  if(Country_Name == "Ireland"){
    return(geographicAreaM49 = 372)
  }
  
  if(Country_Name == "Italy"){
    return(geographicAreaM49 = 380)
  }
  
  if(Country_Name == "Jamaica"){
    return(geographicAreaM49 = 388)
  }
  
  if(Country_Name == "Japan"){
    return(geographicAreaM49 = 58)
  }
  
  if(Country_Name == "Korea, South"){
    return(geographicAreaM49 = 410)
  }
  
  if(Country_Name == "Malaysia"){
    return(geographicAreaM49 = 458)
  }
  
  if(Country_Name == "Mexico"){
    return(geographicAreaM49 = 484)
  }
  
  if(Country_Name == "Mozambique"){
    return(geographicAreaM49 = 508)
  }
  
  if(Country_Name == "Netherlands"){
    return(geographicAreaM49 = 528)
  }
  
  if(Country_Name == "New Caledonia"){
    return(geographicAreaM49 = 540)
  }

  if(Country_Name == "Nigeria"){
    return(geographicAreaM49 = 566)
  }
  
  if(Country_Name == "Norway"){
    return(geographicAreaM49 = 578)
  }
  
  if(Country_Name == "Papua New Guinea"){
    return(geographicAreaM49 = 598)
  }
  
  if(Country_Name == "Philippines"){
    return(geographicAreaM49 = 608)
  }
  
  if(Country_Name == "Poland"){
    return(geographicAreaM49 = 616)
  }
  
  if(Country_Name == "Portugal"){
    return(geographicAreaM49 = 620)
  }
  
  if(Country_Name == "Samoa"){
    return(geographicAreaM49 = 882)
  }
  
  if(Country_Name == "Singapore"){
    return(geographicAreaM49 = 702)
  }
  
  if(Country_Name == "Spain"){
    return(geographicAreaM49 = 724)
  }
  
  if(Country_Name == "Sri Lanka"){
    return(geographicAreaM49 = 144)
  }
  
  if(Country_Name == "Sweden"){
    return(geographicAreaM49 = 752)
  }
  
  if(Country_Name == "Switzerland"){
    return(geographicAreaM49 = 756)
  }
  
  if(Country_Name == "Tanzania"){
    return(geographicAreaM49 = 834)
  }
  
  if(Country_Name == "Thailand"){
    return(geographicAreaM49 = 764)
  }
  
  if(Country_Name == "Union of Soviet Socialist Repu"){
    return(geographicAreaM49 = 810) # maybe USSR(-1991)?
  }
  
  if(Country_Name == "United Kingdom"){
    return(geographicAreaM49 = 826)
  }
  
  if(Country_Name == "United States"){
    return(geographicAreaM49 = 840)
  }
  
  if(Country_Name == "Venezuela"){
    return(geographicAreaM49 = 862)
  }
  
  if(Country_Name == "Vietnam"){
    return(geographicAreaM49 = 704)
  }
  
  if(Country_Name == "Albania"){
    return(geographicAreaM49 = 8)
  }
  
  if(Country_Name == "Algeria"){
    return(geographicAreaM49 = 12)
  }
  
  if(Country_Name == "Argentina"){
    return(geographicAreaM49 = 32)
  }

  if(Country_Name == "Armenia"){
    return(geographicAreaM49 = 51)
  }
    
  if(Country_Name == "Azerbaijan"){
    return(geographicAreaM49 = 31)
  }
  
  if(Country_Name == "Belarus"){
    return(geographicAreaM49 = 112)
  }
  
  if(Country_Name == "Benin"){
    return(geographicAreaM49 = 204)
  }
  
  if(Country_Name == "Brazil"){
    return(geographicAreaM49 = 76)
  }
  
  if(Country_Name == "Bulgaria"){
    return(geographicAreaM49 = 100)
  }
  
  if(Country_Name == "Burkina"){
    return(geographicAreaM49 = 854)
  }
  
  if(Country_Name == "Burma"){
    return(geographicAreaM49 = 104)
  }
  
  if(Country_Name == "Cameroon"){
    return(geographicAreaM49 = 120)
  }
  
  if(Country_Name == "Chad"){
    return(geographicAreaM49 = 148)
  }
  
  if(Country_Name == "China"){
    return(geographicAreaM49 = 1248) # China,Main
  }
  
  if(Country_Name == "Costa Rica"){
    return(geographicAreaM49 = 188)
  }
  
  if(Country_Name == "Dominican Republic"){
    return(geographicAreaM49 = 214)
  }
  
  if(Country_Name == "Egypt"){
    return(geographicAreaM49 = 818)
  }
  
  if(Country_Name == "Ethiopia"){
    return(geographicAreaM49 = 231)
  }
  
  if(Country_Name == "Former Czechoslovakia"){
    return(geographicAreaM49 = 200) # Czechoslovak(-1992)
  }
  
  if(Country_Name == "Former Yugoslavia"){
    return(geographicAreaM49 = 978) # Yugo F Area(1992-)
  }
  
  if(Country_Name == "Georgia"){
    return(geographicAreaM49 = 268)
  }
  
  if(Country_Name == "Germany"){
    return(geographicAreaM49 = 276)
  }
  
  if(Country_Name == "Greece"){
    return(geographicAreaM49 = 300)
  }
  
  if(Country_Name == "Hungary"){
    return(geographicAreaM49 = 348)
  }
  
  if(Country_Name == "Iran"){
    return(geographicAreaM49 = 364)
  }
  
  if(Country_Name == "Iraq"){
    return(geographicAreaM49 = 368)
  }
  
  if(Country_Name == "Kazakhstan"){
    return(geographicAreaM49 = 398)
  }
  
  if(Country_Name == "Kyrgyzstan"){
    return(geographicAreaM49 = 417)
  }
  
  if(Country_Name == "Madagascar"){
    return(geographicAreaM49 = 450)
  }
  
  if(Country_Name == "Mali"){
    return(geographicAreaM49 = 466)
  }
  
  if(Country_Name == "Malta"){
    return(geographicAreaM49 = 470)
  }
  
  if(Country_Name == "Nicaragua"){
    return(geographicAreaM49 = 558)
  }
  
  if(Country_Name == "Pakistan"){
    return(geographicAreaM49 = 586)
  }
  
  if(Country_Name == "Panama"){
    return(geographicAreaM49 = 591)
  }
  
  if(Country_Name == "Paraguay"){
    return(geographicAreaM49 = 600)
  }
  
  if(Country_Name == "Romania"){
    return(geographicAreaM49 = 642)
  }
  
  if(Country_Name == "Russia"){
    return(geographicAreaM49 = 643)
  }
  
  if(Country_Name == "Saudi Arabia"){
    return(geographicAreaM49 = 682)
  }
  
  if(Country_Name == "South Africa"){
    return(geographicAreaM49 = 710)
  }
  
  if(Country_Name == "Sudan"){
    return(geographicAreaM49 = 736) # Sudan (former)
  }
  
  if(Country_Name == "Syria"){
    return(geographicAreaM49 = 760)
  }
  
  if(Country_Name == "Tajikistan"){
    return(geographicAreaM49 = 762)
  }
  
  if(Country_Name == "Togo"){
    return(geographicAreaM49 = 768)
  }
  
  if(Country_Name == "Turkey"){
    return(geographicAreaM49 = 792)
  }
  
  if(Country_Name == "Turkmenistan"){
    return(geographicAreaM49 = 795)
  }
  
  if(Country_Name == "Uganda"){
    return(geographicAreaM49 = 800)
  }
  
  if(Country_Name == "Uzbekistan"){
    return(geographicAreaM49 = 860)
  }
  
  if(Country_Name == "Yemen (Aden)"){
    return(geographicAreaM49 = NA)
  }
  
  if(Country_Name == "Yemen (Sanaa)"){
    return(geographicAreaM49 = NA)  
  }
  
  if(Country_Name == "Zimbabwe"){
    return(geographicAreaM49 = 716)
  }
  
  if(Country_Name == "Bermuda"){
    return(geographicAreaM49 = 60)
  }
  
  if(Country_Name == "Canada"){
    return(geographicAreaM49 = 124)
  }
  
  if(Country_Name == "Chile"){
    return(geographicAreaM49 = 152)
  }
  
  if(Country_Name == "Colombia"){
    return(geographicAreaM49 = 170)
  }
  
  if(Country_Name == "Ecuador"){
    return(geographicAreaM49 = 218)
  }
  
  if(Country_Name == "Faroe Islands"){
    return(geographicAreaM49 = 234)
  }
  
  if(Country_Name == "Finland"){
    return(geographicAreaM49 = 246)
  }
  
  if(Country_Name == "Iceland"){
    return(geographicAreaM49 = 352)
  }  
  
  if(Country_Name == "New Zealand"){
    return(geographicAreaM49 = 554)
  }  
  
  if(Country_Name == "Peru"){
    return(geographicAreaM49 = 604)
  }  
    
  if(Country_Name == "Senegal"){
    return(geographicAreaM49 = 686)
  }  
  
  
  if(Country_Name == "Taiwan"){
    return(geographicAreaM49 = 156)
  }  
  
  
  if(Country_Name == "Congo (Kinshasa)"){
    return(geographicAreaM49 = 178)
  }  
  
  
  if(Country_Name == "Guatemala"){
    return(geographicAreaM49 = 320)
  }  
  
  
  if(Country_Name == "Guinea"){
    return(geographicAreaM49 = 324)
  }  
  
  
  if(Country_Name == "Guinea-Bissau"){
    return(geographicAreaM49 = 624)
  }  
  
  
  if(Country_Name == "Honduras"){
    return(geographicAreaM49 = 58)
  }  
  
  
  if(Country_Name == "Liberia"){
    return(geographicAreaM49 = 430)
  }  
  
  
  if(Country_Name == "Sierra Leone"){
    return(geographicAreaM49 = 694)
  }  
  
  
  if(Country_Name == "Central African Republic"){
    return(geographicAreaM49 = 140)
  }  
  
  
  if(Country_Name == "Gambia, The"){
    return(geographicAreaM49 = 270)
  }  
  
  
  if(Country_Name == "Malawi"){
    return(geographicAreaM49 = 454)
  }  
  
  if(Country_Name == "Morocco"){
    return(geographicAreaM49 = 504)
  }  
  
  if(Country_Name == "Niger"){
    return(geographicAreaM49 = 562)
  }  
  
  if(Country_Name == "Zambia"){
    return(geographicAreaM49 = 894)
  }  
  
  if(Country_Name == "Czech Republic"){
    return(geographicAreaM49 = 203)
  }  
  
  if(Country_Name == "Lithuania"){
    return(geographicAreaM49 = 440)
  }  
  
  if(Country_Name == "Slovakia"){
    return(geographicAreaM49 = 703)
  }  
  
  if(Country_Name == "Ukraine"){
    return(geographicAreaM49 = 804)
  }  
  
  if(Country_Name == "United Arab Emirates"){
    return(geographicAreaM49 = 784)
  }  
  
  if(Country_Name == "Barbados"){
    return(geographicAreaM49 = 52)
  }  
  
  if(Country_Name == "Bolivia"){
    return(geographicAreaM49 = 68)
  }  
  
  if(Country_Name == "Bosnia and Herzegovina"){
    return(geographicAreaM49 = 70)
  }  
  
  if(Country_Name == "Croatia"){
    return(geographicAreaM49 = 191)
  }  
  
  if(Country_Name == "Cuba"){
    return(geographicAreaM49 = 192)
  }  
  
  if(Country_Name == "Cyprus"){
    return(geographicAreaM49 = 196)
  }  
  
  if(Country_Name == "El Salvador"){
    return(geographicAreaM49 = 222)
  }  
  
  if(Country_Name == "Estonia"){
    return(geographicAreaM49 = 233)
  }  
  
  if(Country_Name == "Guyana"){
    return(geographicAreaM49 = 328)
  }  
  
  if(Country_Name == "Israel"){
    return(geographicAreaM49 = 376)
  }  
  
  if(Country_Name == "Jordan"){
    return(geographicAreaM49 = 400)
  }  
  
  if(Country_Name == "Kenya"){
    return(geographicAreaM49 = 404)
  }  
  
  if(Country_Name == "Korea, North"){
    return(geographicAreaM49 = 408)
  }  
  
  if(Country_Name == "Latvia"){
    return(geographicAreaM49 = 428)
  }  
  
  if(Country_Name == "Lebanon"){
    return(geographicAreaM49 = 422)
  }  
  
  if(Country_Name == "Libya"){
    return(geographicAreaM49 = 434)
  }  
  
  if(Country_Name == "Macedonia"){
    return(geographicAreaM49 = 807)
  }  
  
  if(Country_Name == "Netherlands Antilles"){
    return(geographicAreaM49 = 530)
  }  
  
  if(Country_Name == "Serbia"){
    return(geographicAreaM49 = 688)
  }  
  
  if(Country_Name == "Serbia and Montenegro"){
    return(geographicAreaM49 = 891)
  }  
  
  if(Country_Name == "Slovenia"){
    return(geographicAreaM49 = 705)
  }  
  
  if(Country_Name == "Suriname"){
    return(geographicAreaM49 = 740)
  }  
  
  if(Country_Name == "Trinidad and Tobago"){
    return(geographicAreaM49 = 780)
  }  
  
  if(Country_Name == "Tunisia"){
    return(geographicAreaM49 = 788)
  }  
  
  if(Country_Name == "Uruguay"){
    return(geographicAreaM49 = 858)
  }  
  
  if(Country_Name == "Yemen"){
    return(geographicAreaM49 = 887)
  }  
  
  if(Country_Name == "Moldova"){
    return(geographicAreaM49 = 498)
  }  
  
  if(Country_Name == "Somalia"){
    return(geographicAreaM49 = 706)
  }  
  
  if(Country_Name == "Afghanistan"){
    return(geographicAreaM49 = 4)
  }  
  
  if(Country_Name == "Angola"){
    return(geographicAreaM49 = 24)
  }  
  
  if(Country_Name == "Haiti"){
    return(geographicAreaM49 = 332)
  }  
  
  if(Country_Name == "Kuwait"){
    return(geographicAreaM49 = 414)
  }  
  
  if(Country_Name == "Oman"){
    return(geographicAreaM49 = 512)
  }  
  
  if(Country_Name == "Other"){
    return(geographicAreaM49 = NA) ### Other???
  }  
  
  if(Country_Name == "Rwanda"){
    return(geographicAreaM49 = 646)
  }  
  
  if(Country_Name == "Mauritania"){
    return(geographicAreaM49 = 478)
  }  
  
  if(Country_Name == "Cambodia"){
    return(geographicAreaM49 = 116)
  }  
  
  if(Country_Name == "Mauritius"){
    return(geographicAreaM49 = 480)
  }  
# 
#    else 
#      return(geographicAreaM49 = 1000)
}
