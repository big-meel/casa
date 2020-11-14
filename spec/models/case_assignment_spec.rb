require "rails_helper"

RSpec.describe CaseAssignment do
  let(:casa_org_1) { create(:casa_org) }
  let(:casa_case_1) { create(:casa_case, casa_org: casa_org_1) }
  let(:volunteer_1) { create(:volunteer, casa_org: casa_org_1) }
  let(:inactive) { create(:volunteer, :inactive, casa_org: casa_org_1) }
  let(:supervisor) { create(:supervisor, casa_org: casa_org_1) }
  let(:casa_case_2) { create(:casa_case, casa_org: casa_org_1) }
  let(:volunteer_2) { create(:volunteer, casa_org: casa_org_1) }
  let(:casa_org_2) { create(:casa_org) }

  it "only allow active volunteers to be assigned" do
    expect(casa_case_1.case_assignments.new(volunteer: volunteer_1)).to be_valid
    casa_case_1.reload

    expect(casa_case_1.case_assignments.new(volunteer: inactive)).to be_invalid
    casa_case_1.reload

    expect(casa_case_1.case_assignments.new(volunteer: supervisor)).to be_invalid
  end

  it "allows two volunteers to be assigned to the same case" do
    casa_case_1.volunteers << volunteer_1
    casa_case_1.volunteers << volunteer_2
    casa_case_1.save!

    expect(volunteer_1.casa_cases).to eq([casa_case_1])
    expect(volunteer_2.casa_cases).to eq([casa_case_1])
  end

  it "allows volunteer to be assigned to multiple cases" do
    volunteer_1.casa_cases << casa_case_1
    volunteer_1.casa_cases << casa_case_2
    volunteer_1.save!

    expect(casa_case_1.reload.volunteers).to eq([volunteer_1])
    expect(casa_case_2.reload.volunteers).to eq([volunteer_1])
  end

  it "requires case and volunteer belong to the same organization" do
    case_assignment = casa_case_1.case_assignments.new(volunteer: volunteer_1)
    expect { volunteer_1.update(casa_org: casa_org_2) }.to change(case_assignment, :valid?).to false
  end

  describe ".is_active" do
    it "only includes active case assignments" do
      casa_case = create(:casa_case)
      case_assignments = 2.times.map { create(:case_assignment, casa_case: casa_case, volunteer: create(:volunteer, casa_org: casa_case.casa_org)) }
      expect(CaseAssignment.is_active).to eq case_assignments

      case_assignments.first.update(is_active: false)
      expect(CaseAssignment.is_active).to eq [case_assignments.last]
    end
  end
end
