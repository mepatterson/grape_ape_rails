module API
  class Base < GrapeApeRails::API

    grape_apis do
      # always mount admins first and public-facing versions after
      # with newest version lowest
      api "V2" do
        grape_mount :widgets
      end

      api "V1", ['V2', 'V1'] do
        grape_mount :widgets
        grape_mount :monkeys
      end
    end

  end
end
