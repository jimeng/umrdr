require 'spec_helper'

describe Sufia::Forms::CollectionForm do
  describe "#terms" do
    subject { described_class.terms }

    it { is_expected.to eq [:resource_type,
                            :title,
                            :creator,
                            :contributor,
                            :description,
                            :tag,
                            :rights,
                            :publisher,
                            :date_created,
                            :subject,
                            :language,
                            :related_url] }
  end
end
