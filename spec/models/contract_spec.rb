# == Schema Information
#
# Table name: contracts
#
#  id                  :integer          not null, primary key
#  quote_id            :integer
#  customer_request_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  completion_date     :date
#

RSpec.describe Contract, type: :model do
  describe '#validations' do
    it 'has a valid factory' do
      expect(build(:contract)).to be_valid
    end
    it 'should give an error when saving quoteless contract' do
      contract1 = create( quote = true
      )
      expect(contract1).to_not be_valid
    end
  end
end