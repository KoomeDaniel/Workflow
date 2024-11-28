table 50100 "Custom Workflow Header"
{
    Caption = 'Custom Workflow Header';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Custom Workflow List";
    LookupPageId = "Custom Workflow List";


    fields
    {
        field(1; "No."; code[20])
        {
            Caption = 'N0.';
            Editable = false;
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    PurchPayablesSetup.Get();
                    NoSeriesMgt.TestManual(PurchPayablesSetup."Workflow Header No.");
                    "No. Series" := '';


                end;
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No. Series';
        }
        field(3; Description; text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(4; "Approval Status"; Enum "Custom Approval")
        {
            DataClassification = ToBeClassified;
            Caption = 'Approval Status';
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;


    trigger OnInsert()
    begin
        if "No." = '' then begin
            PurchPayablesSetup.Get();
            PurchPayablesSetup.TestField("Workflow Header No.");
            NoSeriesMgt.InitSeries(PurchPayablesSetup."Workflow Header No.", xrec."No. Series", 0D, "No.", "No. Series");
        end;
    end;
}
