require 'rails_helper'

describe Sidebar, type: :model do
  describe '#ordered_sidebars' do
    let(:blog) { create :blog }

    context 'with several sidebars with different positions' do
      let(:search_sidebar) { Sidebar.new(staged_position: 2, blog: blog, type: 'SearchSidebar') }
      let(:static_sidebar) { Sidebar.new(active_position: 1, blog: blog, type: 'SearchSidebar') }

      before do
        search_sidebar.save
        static_sidebar.save
      end

      it 'resturns the sidebars ordered by position' do
        sidebars = Sidebar.ordered_sidebars
        expect(sidebars).to eq([static_sidebar, search_sidebar])
      end
    end

    context 'with an invalid sidebar in the database' do
      before do
        Sidebar.new(type: 'SearchSidebar', staged_position: 1, blog: blog).save
        Sidebar.new(type: 'FooBarSidebar', staged_position: 2, blog: blog).save
      end

      it 'skips the invalid active sidebar' do
        sidebars = Sidebar.ordered_sidebars
        expect(sidebars.size).to eq(1)
        expect(sidebars.first.configuration_class).to eq(SearchSidebar)
      end
    end
  end

  describe '#content_partial' do
    it 'bases the partial name on the configuration class name' do
      expect(Sidebar.new(type: 'SearchSidebar').content_partial).to eq('/search_sidebar/content')
    end
  end

  describe '#configuration_class' do
    let(:sidebar) { Sidebar.new(type: 'ArchivesSidebar') }

    it 'returns the type, classified' do
      expect(sidebar.configuration_class).to eq ArchivesSidebar
    end
  end
end
