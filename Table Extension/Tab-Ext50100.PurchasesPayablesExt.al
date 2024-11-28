tableextension 50100 "Purchases & Payables Ext" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50100; "Workflow Header No."; Code[20])
        {
            Caption = 'Workflow Header No.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}
