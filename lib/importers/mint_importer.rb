require 'types'
require 'importers'

class MintEvent < Event
  key :text, String
  key :mint_description, String
  key :mint_orig_description, String
  key :mint_amount, Float
  key :mint_transactiontype, Integer
  key :mint_category, Integer

  # Transaction constants
  DebitTransaction = 1
  CreditTransaction = 2
  MaximumTransactionValue = 3

  def mint_transactiontype_sym
    return :debit if self.mint_transactiontype == DebitTransaction
    return :credit if self.mint_transactiontype == CreditTransaction
    :unknown
  end

  def content_hash
    Digest::SHA1.hexdigest(self.text + self.authored_on.to_s)
  end
end

class MintImporter
  include Istoria::CsvImportImplementation

  CsvHeaderMap = {
    "Date" => :authored_on,
    "Description" => :mint_description,
    "Original Description" => :mint_orig_description,
    "Amount" => :mint_amount,
    "Transaction Type" => :mint_transactiontype,
    "Category" => :mint_category,
  }

  DataTransformerMap = {
    :authored_on => :parse_mdy_date,
    :mint_description => :passthrough,
    :mint_orig_description => :passthrough,
    :mint_amount => :parse_float,
    :mint_transactiontype => :mint_transactiontype,
    :mint_category => :passthrough,
  }

  def csv_header_map
    CsvHeaderMap 
  end

  def csv_data_transformer_map
    DataTransformerMap 
  end

  def csv_event_class
    MintEvent
  end

  class << self
    include Istoria::StandardParsers

    def mint_transactiontype(value)
      return MintEvent::DebitTransaction if value == "debit"
      return MintEvent::CreditTransaction if value == "credit"
      MintEvent::UnknownTransaction 
    end
  end

  def csv_reject_item?(item)
    item[:mint_category] == "Transfer"
  end

  def csv_add_fields(item)
      item[:mint_amount] = -item[:mint_amount] if item[:mint_transactiontype] == MintEvent::DebitTransaction
      item[:text] = "Spent #{item[:mint_amount]} at #{item[:mint_description]}"
      item[:tags] = [Tag.new(:name => "Mint", :type => Tag::SourceType)]
      item
  end
end
