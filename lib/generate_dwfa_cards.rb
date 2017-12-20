require 'prawn'
require 'prawn/table'
require 'prawn/measurement_extensions'
require 'csv'

DEFENSE_COLOR = {'active'   => '0000FF',
                 'passive'  => 'FF0000',
}
DEFENSE_COLOR.default = '000000'
MARS = %i( cloud_generator combat_deployment crushing_impact
           direhard_crew disruption_generator diving drift elite_crew escort fearless
           flexible_squadron independent_move inventive_scientists kinetic_generator
           mimic_generator minelayer node_disruption_generator repair restricted_boarding
           security_posts small_target special_forces squadron_support
         )

#  bleed             +--------------------------------------------+
#                    |+------------------------------------------+|
#  title box         || flag              name              flag ||
#                    |+------------------------------------------+|
#                    || model type        | VP    | x |          ||
#  info box          || points value  | X | PassD | x |          ||
#                    || squadron size | X | ActD  | x |          ||
#                    |+-------------------------------+          ||
#  stats box         ||  Move  |   DR  |   HP  |  CP  |          ||
#                    ||   x"   |   10  |   10  |  10  |          ||
#                    |+-------------------------------+----------+|
#  weapon box        || WEAPON  | ARC |   MAR     | PB | EF | LR ||
#                    || 1       |     |           |    |    |    ||
#                    || 2       |     |           |    |    |    ||
#                    || 3       |     |           |    |    |    ||
#                    || 4       |     |           |    |    |    ||
#                    || 5       |     |           |    |    |    ||
#                    || 6       |     |           |    |    |    ||
#                    |+---------+-----+-----------+----+----+----+|
#  MAR               || MARs    |                                ||
#  special box       || SPECIAL |                                ||
#                    ||  RULES  |                                ||
#                    |+------------------------------------------+|
#                    +--------------------------------------------+

# 2.5.in height => 180
#    - 4 pt bleed on top and bottom => 172
# 3.5.in width => 252
#    - 4 pt bleed on left and right => 244
TITLE_BOX        = { x: 0,   y: 172,                                                               width: 248, height: 20 }
INFO_BOX         = { x: 0,   y: 172 - TITLE_BOX[:height],                                          width: 172, height: 30 }
STATS_BOX        = { x: 0,   y: 172 - TITLE_BOX[:height] - INFO_BOX[:height],                      width: 172, height: 20 }
PICTURE_BOX      = { x: 172, y: 172 - TITLE_BOX[:height],                                          width: 72,  height: INFO_BOX[:height] + STATS_BOX[:height] }
WEAPONS_BOX      = { x: 0,   y: 172 - TITLE_BOX[:height] - INFO_BOX[:height] - STATS_BOX[:height], width: 248, height: 72 }
MAR_SPECIAL_BOX  = { x: 0,   y: 30,                                                                width: 248, height: 30 }



def massage_line_into_data line
  # iterate through weapon columns and make an array of weapons
  data = line.to_hash
  data[:weapons] = []
  data[:weapon_colors] = []
  weapons = (1..6).each do |index|
              if data["weapon_#{index}_name".to_sym].nil? || data["weapon_#{index}_name".to_sym].empty?
                # do nothing
              else
                weapon = if data["weapon_#{index}_type".to_sym].nil? || data["weapon_#{index}_type".to_sym].empty?
                           "<b>#{data["weapon_#{index}_name".to_sym]}</b>"
                         else
                           "<i>#{data["weapon_#{index}_type".to_sym]}</i> <b>#{data["weapon_#{index}_name".to_sym]}</b>"
                         end
                data[:weapons] << [weapon,
                                   data["weapon_#{index}_arc".to_sym],
                                   data["weapon_#{index}_mars".to_sym],
                                   data["weapon_#{index}_pb".to_sym],
                                   data["weapon_#{index}_ef".to_sym],
                                   data["weapon_#{index}_lr".to_sym],
                                  ]
                data[:weapon_colors] << DEFENSE_COLOR[data["weapon_#{index}_defense".to_sym]]
              end
            end
  if data[:bomber_pb]
    data[:weapons] << ["<b>Bombers</b>",
                       "360°",
                       data[:bomber_mars],
                       data[:bomber_pb],
                       data[:bomber_ef],
                       data[:bomber_lr],
                      ]
    data[:weapon_colors] << DEFENSE_COLOR['active']
  end
  if data[:fighter_pb]
    data[:weapons] << ["<b>Fighters</b>",
                       "360°",
                       data[:fighter_mars],
                       data[:fighter_pb],
                       data[:fighter_ef],
                       data[:fighter_lr],
                      ]
    data[:weapon_colors] << DEFENSE_COLOR['active']
  end
  data
end

#                     +------------------------------------------+
#  title box          | flag       name                     flag |
#                     +------------------------------------------+
def title_box data
  bounding_box [0, bounds.top], width: TITLE_BOX[:width],
                                height: TITLE_BOX[:height] do

    table_data = [[nil,data[:name],nil]]
    image_name = "../assets/#{data[:flag]}"
    if File.exist? image_name
      table_data[0][0] = {image: image_name, position: :left, vposition: :center, fit: [22,22]}
      table_data[0][2] = {image: image_name, position: :center, vposition: :center, fit: [22,22]}
    end
    font_size 16 do
    table table_data do
      row(0).font_style = :bold
      row(0).borders = []
      column(0).width = 26
      column(1).width = 196
      column(2).width = 26
      row(0).height = 20
      cells.align = :center
      cells.overflow = :shrink_to_fit
      cells.padding = 1
    end
    end
    # bounding_box [0, bounds.top], width: TITLE_BOX[:height],
    #                             height: TITLE_BOX[:height] do
    #   stroke_bounds

    # # if image exists
    # if File.exist? image_name
    #   image image_name, position: :left,
    #                     vposition: :center,
    #                     fit: [TITLE_BOX[:height], TITLE_BOX[:height]]
    # end
    #                             end
    # bounding_box [220, bounds.top], width: TITLE_BOX[:height],
    #                             height: TITLE_BOX[:height] do
    #   stroke_bounds
    # if File.exist? image_name
    #   image image_name, position: :right,
    #                     vposition: :center,
    #                     fit: [TITLE_BOX[:height], TITLE_BOX[:height]]
    # end
    #                             end
    # text_box data[:name], at: [TITLE_BOX[:height] + 4, bounds.top - 2],
    #                       width: 2.5.in, #TITLE_BOX[:width] - 2 * TITLE_BOX[:height] - 8,
    #                       height: TITLE_BOX[:height] - 4,
    #                       align: :center,
    #                       valign: :center,
    #                       overflow: :shrink_to_fit,
    #                       padding: 2,
    #                       size: 20,
    #                       style: :bold

  end
end

#                     +-------------------------------+----------+
#  title box          | flag       name                     flag |
#                     +------------------------------------------|
#                     | model type        | VP    | x | picture  |
#  info box           | points value  | X | Act.D | x | box      |
#                     | squadron size | X | Pas.D | x |          |
#                     +-------------------------------+          |
#  stats box          |  Move  |   DR  |   HP  |  CP  |          |
#                     |   x"   |   10  |   10  |  10  |          |
#                     +-------------------------------+----------+
def picture_box data
  bounding_box [PICTURE_BOX[:x], PICTURE_BOX[:y]], width: PICTURE_BOX[:width],
                                                height: PICTURE_BOX[:height] do
    # if image exists
    image_name = "../assets/#{data[:image]}"
    if data[:image] && File.exist?(image_name)
      image image_name, position: :center,
                        vposition: :center,
                        fit: [PICTURE_BOX[:width] - 2, PICTURE_BOX[:height] - 2]
    end
  end
end

#                     +-------------------------------|          |
#                     | model type        | VP    | x | picture  |
#  info box           | points value  | X | Act.D | x | box      |
#                     | squadron size | X | Pas.D | x |          |
#                     +-------------------------------+          |
def info_box data
  bounding_box [INFO_BOX[:x], INFO_BOX[:y]], width: INFO_BOX[:width],
                                             height: INFO_BOX[:height],
                                             padding: 0 do
    table_data = [[{content: data[:model_type], colspan: 2}, 'VP', data[:vp]],
                  ['Point Value', data[:point_value], 'Act Def', data[:active_defense]],
                  ['Squadron Size', data[:squadron_size], 'Pass Def', data[:passive_defense]]
                 ]
    font_size 7 do
    table table_data do
      column(0).font_style = :bold
      column(2).font_style = :bold
      column(0).width = 86
      column(1).width = 22
      column(2).width = 43
      column(3).width = 21
          column(0).background_color = "CCCCCC"
          row(0).column(2..3).background_color = "00FF00"
          row(1).column(2..3).background_color = "0000FF"
          row(2).column(2..3).background_color = "FF0000"
          row(1..2).column(2..3).text_color = "FFFFFF"
      rows(0..2).height = INFO_BOX[:height] / 3 - 0.01
      cells.align = :center
      #cells.overflow = :shrink_to_fit
      cells.padding = 1
      # cells.valign = :center
    end
    end
  end

end

#                     +-------------------------------+          |
#  stats box          |  Move  |   DR  |   HP  |  CP  | picture  |
#                     |   x"   |   10  |   10  |  10  | box      |
#                     +-------------------------------+----------+
def stats_box data
  bounding_box [STATS_BOX[:x], STATS_BOX[:y]], width: STATS_BOX[:width],
                                               height: STATS_BOX[:height] do
    font_size 7 do
    table [%w(Move DR HP CP),
           [data[:move], data[:dr], data[:hp], data[:cp]]] do
      row(0).font_style = :bold
      row(0).background_color = "CCCCCC"
      rows(0..1).height = STATS_BOX[:height] / 2 - 0.15
      cells.align = :center
      cells.overflow = :shrink_to_fit
      cells.padding = 1
      # cells.valign = :center
      cells.width = STATS_BOX[:width] / 4.0
    end
    end
  end
end

#                     +-------------------------------+----------+
#  weapon box         | Weapon  | Arc |   MAR     | PB | EF | LR |
#                     | 1       |     |           |    |    |    |
#                     | 2       |     |           |    |    |    |
#                     | 3       |     |           |    |    |    |
#                     | 4       |     |           |    |    |    |
#                     | 5       |     |           |    |    |    |
#                     | 6       |     |           |    |    |    |
#                     +---------+-----+-----------+----+----+----+
def weapons_box data
  bounding_box [WEAPONS_BOX[:x], WEAPONS_BOX[:y]], width: WEAPONS_BOX[:width],
                                                   height: WEAPONS_BOX[:height] do
    table_data = [%w( Weapon Arc MAR PB EF LR )]
    table_data += data[:weapons]
    font_size 8 do
      table table_data do
        column(2).font_style = :italic
        row(0).font_style = :bold
        row(0).background_color = "CCCCCC"
        rows(0).height = 11
        rows(1..6).height = (WEAPONS_BOX[:height] - 11)  / (table_data.size - 1).to_f - 0.05
        (1..6).each do |index|
          row(index).text_color = data[:weapon_colors][index-1]
        end
        # width 244
        column(0).width = 86
        column(1).width = 30
        column(2).width = 75
        column(3).width = 19
        column(4).width = 19
        column(5).width = 19
        cells.align = :center
        cells.overflow = :shrink_to_fit
        cells.padding = 1
        #cells.valign = :center
        cells.inline_format = true
      end
    end
  end
end

#                     +---------+-----+-----------+----+----+----+
#  MAR                | MARs    |                                |
#  special box        | Special |                                |
#                     |  Rules  |                                |
#                     +------------------------------------------+
def mar_special_box data
  bounding_box [MAR_SPECIAL_BOX[:x], MAR_SPECIAL_BOX[:y]], width: MAR_SPECIAL_BOX[:width],
                                                           height: MAR_SPECIAL_BOX[:height],
                                                           padding: 0 do
    mars_text = if data.has_key?(:mars)
                  data[:mars] || ''
                else
                  mars_array = MARS.collect do |mar|
                                 if mar == :combat_deployment && data[:combat_deployment_model]
                                   "Combat Deployment (#{data[:combat_deployment_model]}, #{data[:combat_deployment_number]})"
                                 elsif mar == :squadron_support && data[:squadron_support_model]
                                   "Squadron Support (#{data[:squadron_support_model]}, #{data[:squadron_support_number]})"
                                 else
                                   if data[mar]
                                     if data[mar] == 'x'
                                       mar.to_s.split('_').collect(&:capitalize).join(' ')
                                     else
                                       "#{mar.to_s.split('_').collect(&:capitalize).join(' ')} (#{data[mar]})"
                                     end
                                   end
                                 end
                               end
                  mars_array.compact.join ', '
                end
    special_rules_text = if data[:special_rules] && data[:faction_rules]
                           "#{data[:special_rules]}\n#{data[:faction_rules]}"
                         elsif data[:faction_rules]
                           data[:faction_rules]
                         else
                           data[:special_rules]
                         end

    font_size 7 do
      table_data = [['MARs', mars_text], ["Special\nRules", special_rules_text ]]
      table table_data do
        column(0).font_style = :bold
        # column(0).valign = :center
        column(0).align = :center
        column(0).background_color = "CCCCCC"
        column(0).width = 36
        column(1).width = 212
        row(0).height = 10
        row(1).height = 19.85
        row(0).column(1).font_style = :italic
        row(0).column(1).align = :center
        cells.inline_format = true
        cells.overflow = :shrink_to_fit
        cells.padding = 1
      end
    end
  end
end

def draw_card line
  # inherits bounding box 2.5 in tall and 3.5 in wide
  data = massage_line_into_data line

  title_box data
  picture_box data
  info_box data
  stats_box data
  weapons_box data
  mar_special_box data
end

csv_name = ARGV[0]
csv_name =~ /([\w_-].+)\.csv/
pdf_name = "#{$1}.pdf"

Prawn::Document.generate("../#{pdf_name}",
                         # page_size: [5.1.in, 3.6.in],
                         top_margin: 0.5.in,
                         bottom_margin: 0.5.in,
                         left_margin: 0.75.in,
                         right_margin: 0.75.in
                         # margin: [top,right, bottom, left]
                        ) do
  define_grid columns: 2, rows: 4, gutter: 8
  # define_grid columns: 1, rows: 1, gutter: 0
  card_count = 0
  CSV.foreach(csv_name, headers: true,
                        header_converters: :symbol
             ) do |line|
    if line[:name]
      row = card_count / 2
      column = card_count % 2
      grid(row, column).bounding_box do
        stroke_bounds

        puts "Drawing card for #{line[:name]}"
        draw_card line
      end
      if card_count  == 7
        start_new_page
        card_count = 0
      else
        card_count += 1
      end
    end
  end
end
