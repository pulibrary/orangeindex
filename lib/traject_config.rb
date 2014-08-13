# Traject config goes here
require 'traject/macros/marc21_semantics'
require 'traject/macros/marc_format_classifier'
require 'lib/translation_map'
require 'lib/umich_format'
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats

settings do
  # Where to find solr server to write to
  provide "solr.url", "http://localhost:8983/solr/blacklight-core"

  # If you are connecting to Solr 1.x, you need to set
  # for SolrJ compatibility:
  # provide "solrj_writer.parser_class_name", "XMLResponseParser"

  # solr.version doesn't currently do anything, but set it
  # anyway, in the future it will warn you if you have settings
  # that may not work with your version.
  provide "solr.version", "4.9.0"

  # default source type is binary, traject can't guess
  # you have to tell it.
  provide "marc_source.type", "xml"

  # various others...
  provide "solrj_writer.commit_on_close", "true"

  # By default, we use the Traject::MarcReader
  # One altenrnative is the Marc4JReader, using Marc4J. 
  # provide "reader_class_name", "Traject::Marc4Reader"
  # If we're reading binary MARC, it's best to tell it the encoding. 
  provide "marc4j_reader.source_encoding", "UTF-8" # or 'UTF-8' or 'ISO-8859-1' or whatever. 
end

to_field 'id', extract_marc('001', :first => true)


# Author/Artist:
#    100 XX aqbcdek A aq
#    110 XX abcdefgkln A ab
#    111 XX abcdefgklnpq A ab
to_field 'author_display', extract_marc('100aqbcdek:110abcdefgkln:111abcdefgklnpq', :trim_punctuation => true, :first => true)
to_field 'author_sort', extract_marc('100aqbcdek:110abcdefgkln:111abcdefgklnpq', :trim_punctuation => true, :first => true)
to_field 'author_t', extract_marc('100aqbcdek:110abcdefgkln:111abcdefgklnpq')


# Uniform title:
#    130 XX apldfhkmnorst T ap
#    240 XX {a[%}pldfhkmnors"]" T ap
to_field 'uniform_title_display', extract_marc('130apldfhkmnorst:240apldfhkmnors', :trim_punctuation => true, :first => true)


# Title:
#    245 XX abchknps
to_field 'title_display', extract_marc('245abchknps', :alternate_script => false)
to_field 'title_vern_display', extract_marc('245abchknps', :alternate_script => :only)
to_field 'title_sort', marc_sortable_title
to_field 'title_t', extract_marc('245abchknps')

# Compiled/Created:
#    245 XX fg
to_field 'compiled_created_display', extract_marc('245fg')
to_field 'compiled_created_t', extract_marc('245abchknps')

# Edition
#    250 XX ab
to_field 'edition_display', extract_marc('250ab')

# Published/Created:
#    260 XX abcefg
#    264 XX abc
to_field 'pub_created_display', extract_marc('260abcefg:264abc', :first => true)
to_field 'pub_created_t', extract_marc('260abcefg:264abc', :first => true)

# Medium/Support:
#    340 XX 3abcdefhl


to_field 'format' do |record, accumulator|
    fmt = UMichFormat.new(record).format_and_types
    # accumulator << TranslationMap.new("umich/format")[ fmt ]
    accumulator << TranslationMap.new("umich/format").translate_array!(fmt)
end

to_field 'medium_support_display', extract_marc('340')


# Electronic access:
#    3000 - really 856
#    most have first sub as 4, a few 0,1,7
#    treat the same
#    $u is for the link
#    $z, $2 and $3 seem to show alt text
to_field 'electronic_access_display', extract_marc('856u:856z23')

# Description:
   # 254 XX a
   # 255 XX abcdefg
   # 342 XX 2abcdefghijklmnopqrstuv
   # 343 XX abcdefghi
   # 352 XX abcdegi
   # 355 XX abcdefghj
   # 507 XX ab
   # 256 XX a
   # 516 XX a
   # 753 XX abc
   # 755 XX axyz
   # 300 XX 3abcefg
   # 306 XX a
   # 515 XX a
   # 362 XX az
to_field 'description_display', extract_marc('254a:255abcdefg:3422abcdefghijklmnopqrstuv:343abcdefghi:352abcdegi:355abcdefghj:507ab:256a:516a:753abc:755axyz:3003abcefg:306a:515a:362az')
to_field 'description_t', extract_marc('254a:255abcdefg:3422abcdefghijklmnopqrstuv:343abcdefghi:352abcdegi:355abcdefghj:507ab:256a:516a:753abc:755axyz:3003abcefg:306a:515a:362az')

# Arrangement:
# #    351 XX 3abc
to_field 'arrangement_display', extract_marc('351abc')

# Translation of:
#    765 XX at
to_field 'translation_of_display', extract_marc('765at')


# Translated as:
#    767 XX at
to_field 'translated_as_display', extract_marc('767at')

# Issued with:
#    777 XX at
to_field 'issued_with_display', extract_marc('777at')

# Continues:
#    780 00 at
#    780 02 at
to_field 'continues_display', extract_marc('780|00|a:780|02|at')

# Continues in part:
#    780 01 at
#    780 03 at
to_field 'continues_in part_display', extract_marc('780|01|a:780|03|at')

# Formed from:
#    780 04 at
to_field 'formed_from_display', extract_marc('780|04|at')

# Absorbed:
#    780 05 at
to_field 'absorbed_display', extract_marc('780|05|at')

# Absorbed in part:
#    780 06 at
to_field 'absorbed_in_part_display', extract_marc('780|06|at')

# Separated from:
#    780 07 at
to_field 'separated_from_display', extract_marc('780|07|at')

# Continued by:
#    785 00 at
#    785 02 at
to_field 'continued_by_display', extract_marc('785|00|a:785|02|at')

# Continued in part by:
#    785 01 at
#    785 03 at
to_field 'continued_in part_by_display', extract_marc('785|01|a:785|03|at')

# Absorbed by:
#    785 04 at
to_field 'absorbed_by_display', extract_marc('785|04|at')

# Absorbed in part by:
#    785 05 at
to_field 'absorbed_in_part_by_display', extract_marc('785|05|at')

# Split into:
#    785 06 at
to_field 'split_into_display', extract_marc('785|06|at')

# Merged to form:
#    785 07 at
to_field 'merged_to_form_display', extract_marc('785|07|at')

# Changed back to:
#    785 08 at
to_field 'changed_back_to_display', extract_marc('785|08|at')

# Frequency:
#    310 XX ab
to_field 'frequency_display', extract_marc('310ab')

# Former frequency:
#    321 XX a
to_field 'former_frequency_display', extract_marc('321a')

# Has supplement:
#    770 XX at
to_field 'has_supplement_display', extract_marc('770at')

# Supplement to:
#    772 XX at
to_field 'supplement_to_display', extract_marc('772at')

# Linking notes:
#    580 XX a
to_field 'linking_notes_display', extract_marc('580a')

# Subseries of:
#    760 XX at
to_field 'subseries_of_display', extract_marc('760at')

# Has subseries:
#    762 XX at
to_field 'has_subseries_display', extract_marc('762at')

# Series:
#    400 XX abcdefgklnpqtuvx
#    410 XX abcdefgklnptuvx
#    411 XX acdefgklnpqtuv
#    440 XX anpvx
#    490 XX avx
#    800 XX abcdefghklmnopqrstuv
#    810 XX abcdefgklnt
#    811 XX abcdefghklnpqstuv
#    830 XX adfghklmnoprstv
#    840 XX anpv
to_field 'series_display', extract_marc('400abcdefgklnpqtuvx:410abcdefgklnptuvx:411acdefgklnpqtuv:440anpvx:490avx:800abcdefghklmnopqrstuv:810abcdefgklnt:811abcdefghklnpqstuv:830adfghklmnoprstv:840anpv')

# to_field 'Other version(s)_display', extract_marc()
# # #    3500 020Z020A
# # #    3500 020A020Z
# # #    3500 024A022A
# # #    3500 022A024A
# # #    3500 BBID776W
# # #    3500 BBID787W
# # #    3500 776X022A
# # #    3500 022A776X
# # #    3500 020A776Z
# # #    3500 776Z020A

# to_field 'Contained in_display', extract_marc()
# # #    3500 BBID773W

# to_field 'Restrictions note_display', extract_marc()
# # #    506 XX 3abcde

# to_field 'Biographical/Historical note_display', extract_marc()
# # #    545 XX ab

# to_field 'Summary note_display', extract_marc()
# # #    520 XX 3ab

# to_field 'Notes_display', extract_marc()
# # #    500 XX 3a
# # #    501 XX a
# # #    503 XX a
# # #    502 XX a
# # #    504 XX ab
# # #    508 XX a
# # #    513 XX ab
# # #    514 XX abcdefghijkm
# # #    515 XX a
# # #    518 XX 3a
# # #    521 XX 3ab
# # #    522 XX a
# # #    523 XX a
# # #    525 XX a
# # #    527 XX a
# # #    534 XX abcefklmnpt
# # #    535 XX 3abcdg
# # #    536 XX abcdefgh
# # #    537 XX a
# # #    538 XX a
# # #    544 XX 3abcden
# # #    547 XX a
# # #    550 XX a
# # #    556 XX a
# # #    562 XX 3abcde
# # #    565 XX 3abcde
# # #    567 XX a
# # #    570 XX a

# to_field 'Binding note_display', extract_marc()
# # #    563 XX au3

# to_field 'Local notes_display', extract_marc()
# # #    590 XX a
# # #    591 XX a
# # #    592 XX a

# to_field 'Rights and reproductions note_display', extract_marc()
# # #    540 XX 3abcd

# to_field 'Exhibitions note_display', extract_marc()
# # #    585 XX 3a

# to_field 'Participant(s)/Performer(s)_display', extract_marc()
# # #    511 XX a

# to_field 'Language(s)_display', extract_marc()
# # #    546 XX 3a

# to_field 'Script_display', extract_marc()
# # #    546 XX b

# to_field 'Contents_display', extract_marc()
# # #    505 0X agrt
# # #    505 8X agrt

# to_field 'Incomplete contents_display', extract_marc()
# # #    505 1X agrt

# to_field 'Partial contents_display', extract_marc()
# # #    505 2X agrt

# to_field 'Provenance_display', extract_marc()
# # #    561 XX 3ab
# # #    796 XX abcqde
# # #    797 XX abcqde

# to_field 'Source of acquisition_display', extract_marc()
# # #    541 XX abcdefhno36

# to_field 'Publications about_display', extract_marc()
# # #    581 XX az36

# to_field 'Indexed in_display', extract_marc()
# # #    510 0X 3abc
# # #    510 1X 3abc
# # #    510 2X 3abc

# to_field 'References_display', extract_marc()
# # #    510 3X 3abc
# # #    510 4X 3abc

# to_field 'Cite as_display', extract_marc()
# # #    524 XX 23a

# to_field 'Other format(s)_display', extract_marc()
# # #    530 XX 3abcd
# # #    533 XX 3abcdefmn

# to_field 'Cumulative index/Finding aid_display', extract_marc()
# # #    555 XX 3abcd

# to_field 'Subject(s)_display', extract_marc()
# # #    600 XX acdfklmnopqrst{v--%}{x--%}{y--%}{z--%} S abcdfklmnopqrtvxyz
# # #    610 XX abfklmnoprst{v--%}{x--%}{y--%}{z--%} S abfklmnoprstvxyz
# # #    611 XX abcdefgklnpqst{v--%}x--%}{y--%}{z--%} S abcdefgklnpqstvxyz
# # #    630 XX adfgklmnoprst{v--%}{x--%}{y--%}{z--%} S adfgklmnoprstvxyz
# # #    650 XX abc{v--%}{x--%}{z--%}{y--%} S abcvxyz
# # #    651 XX a{v--%}{x--%}{y--%}{z--%} S avxyz

# to_field 'Form/Genre_display', extract_marc()
# # #    655 |7 a{v--%}{x--%}{y--%}{z--%} S avxyz

# to_field 'Related name(s)_display', extract_marc()
# # #    700 XX aqbcdefghklmnoprstx A aq
# # #    710 XX abcdefghklnoprstx A ab

# to_field 'Place name(s)_display', extract_marc()
# # #    752 XX abcd

# to_field 'Other title(s)_display', extract_marc()
# # #    246 XX abfnp
# # #    210 XX ab
# # #    211 XX a
# # #    212 XX a
# # #    214 XX a
# # #    222 XX ab
# # #    242 XX abchnp
# # #    243 XX adfklmnoprs
# # #    247 XX abfhnp
# # #    730 XX aplskfmnor
# # #    740 XX ahnp

# to_field 'In_display', extract_marc()
# # #    773 XX 3abdghikmnoprst

# to_field 'Constituent part(s)_display', extract_marc()
# # #    774 XX abcdghikmnrstu

# to_field 'ISBN_display', extract_marc()
# # #    020 XX a

# to_field 'ISSN_display', extract_marc()
# # #    022 XX a

# to_field 'SuDoc no._display', extract_marc()
# # #    086 XX a

# to_field 'Tech. report no._display', extract_marc()
# # #    027 XX a
# # #    088 XX a

# to_field 'Publisher. no._display', extract_marc()
# # #    028 XX a

# to_field 'Standard no._display', extract_marc()
# # #    010 XX a
# # #    030 XX a

# to_field 'Original language_display', extract_marc()
# # #    880 XX abc

# to_field 'Related record(s)_display', extract_marc()
# # #    3500 BBID774W

# to_field 'Holdings information_display', extract_marc()
# # #    9000


# # From displayh.cfg

# to_field 'Location_display', extract_marc() +No location specified
# # #    1000

# to_field 'Call number_display', extract_marc() +No call number available
# # #    852 XX ckhij
# # 
# to_field 'dat_number_display', extract_marc('852ckhij')


# to_field 'Item details_display', extract_marc()
# # Item details:
# # HTML:852||b:<a href="javascript:MapInfo('{b}');" class='loc_{b}'>Where to find it</a>
# # Google Books:
# # HTML:852||b:<div id="googleInfo"></div>


# to_field 'Order information_display', extract_marc()
# # #    1030


# to_field 'Shelving title_display', extract_marc()
# # #    852 XX l


# to_field 'E-items_display', extract_marc()
# # #    1050


# to_field 'Status_display', extract_marc()
# # #    1012


# to_field 'Location has_display', extract_marc()
# # #    1040
# # #    866 |0 az
# # #    866 |1 az
# # #    866 |2 az
# # #    866 30 az
# # #    866 31 az
# # #    866 32 az
# # #    866 40 az
# # #    866 41 az
# # #    866 42 az
# # #    866 50 az
# # #    866 51 az
# # #    866 52 az
# # #    899 XX a

# to_field 'Location has (current)_display', extract_marc()
# # #    866 || az
# # #    1020


# to_field 'Supplements_display', extract_marc()
# # #    1042
# # #    867 XX az
# # #    1022


# to_field 'Indexes_display', extract_marc()
# # #    1044
# # #    868 XX az
# # #    1024


# to_field 'Notes_display', extract_marc()
# # #    852 XX z


# to_field 'Linked resources_display', extract_marc()
# # #    3000



# Other version(s):
#    3500 020Z020A
#    3500 020A020Z
#    3500 024A022A
#    3500 022A024A
#    3500 BBID776W
#    3500 BBID787W
#    3500 776X022A
#    3500 022A776X
#    3500 020A776Z
#    3500 776Z020A
# Contained in:
#    3500 BBID773W
# Restrictions note:
#    506 XX 3abcde
# Biographical/Historical note:
#    545 XX ab
# Summary note:
#    520 XX 3ab
# Notes:
#    500 XX 3a
#    501 XX a
#    503 XX a
#    502 XX a
#    504 XX ab
#    508 XX a
#    513 XX ab
#    514 XX abcdefghijkm
#    515 XX a
#    518 XX 3a
#    521 XX 3ab
#    522 XX a
#    523 XX a
#    525 XX a
#    527 XX a
#    534 XX abcefklmnpt
#    535 XX 3abcdg
#    536 XX abcdefgh
#    537 XX a
#    538 XX a
#    544 XX 3abcden
#    547 XX a
#    550 XX a
#    556 XX a
#    562 XX 3abcde
#    565 XX 3abcde
#    567 XX a
#    570 XX a
# Binding note:
#    563 XX au3
# Local notes:
#    590 XX a
#    591 XX a
#    592 XX a
# Rights and reproductions note:
#    540 XX 3abcd
# Exhibitions note:
#    585 XX 3a
# Participant(s)/Performer(s):
#    511 XX a
# Language(s):
#    546 XX 3a
# Script:
#    546 XX b
# Contents:
#    505 0X agrt
#    505 8X agrt
# Incomplete contents:
#    505 1X agrt
# Partial contents:
#    505 2X agrt
# Provenance:
#    561 XX 3ab
#    796 XX abcqde
#    797 XX abcqde
# Source of acquisition:
#    541 XX abcdefhno36
# Publications about:
#    581 XX az36
# Indexed in:
#    510 0X 3abc
#    510 1X 3abc
#    510 2X 3abc
# References:
#    510 3X 3abc
#    510 4X 3abc
# Cite as:
#    524 XX 23a
# Other format(s):
#    530 XX 3abcd
#    533 XX 3abcdefmn
# Cumulative index/Finding aid:
#    555 XX 3abcd
# Subject(s):
#    600 XX acdfklmnopqrst{v--%}{x--%}{y--%}{z--%} S abcdfklmnopqrtvxyz
#    610 XX abfklmnoprst{v--%}{x--%}{y--%}{z--%} S abfklmnoprstvxyz
#    611 XX abcdefgklnpqst{v--%}x--%}{y--%}{z--%} S abcdefgklnpqstvxyz
#    630 XX adfgklmnoprst{v--%}{x--%}{y--%}{z--%} S adfgklmnoprstvxyz
#    650 XX abc{v--%}{x--%}{z--%}{y--%} S abcvxyz
#    651 XX a{v--%}{x--%}{y--%}{z--%} S avxyz
# Form/Genre:
#    655 |7 a{v--%}{x--%}{y--%}{z--%} S avxyz
# Related name(s):
#    700 XX aqbcdefghklmnoprstx A aq
#    710 XX abcdefghklnoprstx A ab
# Place name(s):
#    752 XX abcd
# Other title(s):
#    246 XX abfnp
#    210 XX ab
#    211 XX a
#    212 XX a
#    214 XX a
#    222 XX ab
#    242 XX abchnp
#    243 XX adfklmnoprs
#    247 XX abfhnp
#    730 XX aplskfmnor
#    740 XX ahnp
# In:
#    773 XX 3abdghikmnoprst
# Constituent part(s):
#    774 XX abcdghikmnrstu
# ISBN:
#    020 XX a
# ISSN:
#    022 XX a
# SuDoc no.:
#    086 XX a
# Tech. report no.:
#    027 XX a
#    088 XX a
# Publisher. no.:
#    028 XX a
# Standard no.:
#    010 XX a
#    030 XX a
# Original language:
#    880 XX abc
# Related record(s):
#    3500 BBID774W
# Holdings information:
#    9000
