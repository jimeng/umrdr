require 'rails_helper'

describe 'curation_concerns/base/show.html.erb' do
  let(:user) {User.new(email:'demo@demo.com', id: 'user1')}
  let(:ability) {Ability.new(user)}

  context 'Showing a Generic Work with zero FileSets' do
    let(:generic_work) { GenericWork.new(id: '456', title: ['Demo Work']) }
    let(:solr_doc) {
      solr_hash = generic_work.to_solr.tap do |doc|
        doc['object_profile_ssm'] = Array(doc['object_profile_ssm'])
      end
      SolrDocument.new(solr_hash)
    }
    let(:work_presenter) {Umrdr::WorkShowPresenter.new(solr_doc, ability, nil)}

    before do
      # Assign the instance variable @presenter that the view uses.
      assign(:presenter, work_presenter)
      # Mock the cancancan permissions calls.
      allow(view).to receive(:can?).with(:edit, String).and_return(false)
      allow(view).to receive(:can?).with(:collect, String).and_return(false)
      # Render the template in the top level describe string
      # equivalent to template: 'curation_concerns/base/show.html.erb'
      render
    end

    it 'renders links to all member FileSets' do
      expect(rendered).not_to have_content('filename01.txt')
    end
  end

  # Not entirely sure there is a clean way to do this short of fully creating and saving
  # a work with a dozen fully created FileSets.  Knowing and mocking the method by which
  # the work gets the FileSet presenters makes this into a test of rails render
  # Make this a slow test and fully create the required components
  #    or
  # Directly test the call that gets the member presenters.
  # I'm inclined to do the former.
  describe 'Showing a Generic Work with more than 10 attached FileSets' do
    let(:file_sets) { (1..15).map{|i| FileSet.new(id: i.to_s, label: "filename#{i}")} }
    let(:generic_work) {
      GenericWork.new(id: '456', title: ['Demo Work']).tap do |work|
        file_sets.each{|file| work.ordered_members << file }
      end
    }
    let(:solr_doc) {
      solr_hash = generic_work.to_solr.tap do |doc|
        doc['object_profile_ssm'] = Array(doc['object_profile_ssm'])
      end
      SolrDocument.new(solr_hash)
    }
    let(:work_presenter) {Umrdr::WorkShowPresenter.new(solr_doc, ability, nil)}

    before do
      # Assign the instance variable @presenter that the view uses.
      assign(:presenter, work_presenter)
      # Mock the cancancan permissions calls.
      allow(view).to receive(:can?).with(:edit, String).and_return(false)
      allow(view).to receive(:can?).with(:collect, String).and_return(false)
      # Render the template in the top level describe string
      # equivalent to template: 'curation_concerns/base/show.html.erb'
      render
    end

    it 'renders links to all member FileSets' do
      skip 'Pending fully creating Work with FileSets.'
    end
  end
end
