codeunit 50100 "Custom Workflow Mgmt"
{
    procedure CheckApprovalsWorkflowEnabled(var RecRef: RecordRef): Boolean
    begin
        if not WorkflowMgt.CanExecuteWorkflow(RecRef, GetWorkflowCode(RunWorkFlowOnSendForApprovalCode, RecRef)) then begin
            Error(NoWorkflowEnabledErr);
        end;
        exit(true);
    end;

    procedure GetWorkflowCode(WorkflowCode: code[128]; RecRef: RecordRef): code[128]
    begin
        exit(DelChr(StrSubstNo(WorkflowCode, RecRef.Name), '=', ' '));//DelChr deletes any occurence of a space or a - in the string
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendWorkFlowForApproval(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelWorkFlowForApproval(RecRef: RecordRef)
    begin
    end;
    //Add Events to the Library
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
        Recref: RecordRef;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        Recref.Open(Database::"Custom Workflow Header");
        WorkflowEventHandling.AddEventToLibrary(GetWorkflowCode(RunWorkFlowOnSendForApprovalCode, Recref), Database::"Custom Workflow Header",
          GetWorkflowEventDesc(WorkflowSendForApprovalEventDescTxt, Recref), 0, false);
        WorkflowEventHandling.AddEventToLibrary(GetWorkflowCode(RunWorkFlowOnCancelForApprovalCode, Recref), Database::"Custom Workflow Header",
          GetWorkflowEventDesc(WorkflowCancelForApprovalEventDescTxt, Recref), 0, false);
    end;
    //Subscribe
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Workflow Mgmt", 'OnSendWorkFlowForApproval', '', false, false)]
    local procedure RunWorkflowOnSendWorkFlowForApproval(RecRef: RecordRef)
    begin
        WorkflowMgt.HandleEvent(GetWorkflowCode(RunWorkFlowOnSendForApprovalCode, RecRef), RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Workflow Mgmt", 'OnCancelWorkFlowForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelWorkFlowForApproval(RecRef: RecordRef)
    begin
        WorkflowMgt.HandleEvent(GetWorkflowCode(RunWorkFlowOnCancelForApprovalCode, RecRef), RecRef);
    end;

    procedure GetWorkflowEventDesc(WorkflowEventDesc: Text; RecRef: RecordRef): Text
    begin
        exit(StrSubstNo(WorkflowEventDesc, RecRef.Name));
    end;
    //handle the event
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CustomWorkflowHdr: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHdr);
                    CustomWorkflowHdr.validate("Approval Status", CustomWorkflowHdr."Approval Status"::Open);
                    CustomWorkflowHdr.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        CustomWorkflowHdr: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHdr);
                    CustomWorkflowHdr.validate("Approval Status", CustomWorkflowHdr."Approval Status"::Pending);
                    CustomWorkflowHdr.Modify(true);
                    Variant := CustomWorkflowHdr;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        CustomWorkflowHdr: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHdr);
                    ApprovalEntryArgument."Document No." := CustomWorkflowHdr."No.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CustomWorkflowHdr: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHdr);
                    CustomWorkflowHdr.Validate("Approval Status", CustomWorkflowHdr."Approval Status"::Approved);
                    CustomWorkflowHdr.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        RecRef: RecordRef;
        CustomWorkflowHdr: Record "Custom Workflow Header";
    begin
        case ApprovalEntry."Table ID" of
            Database::"Custom Workflow Header":
                begin
                    RecRef.Open(ApprovalEntry."Table ID");
                    if CustomWorkflowHdr.Get(ApprovalEntry."Document No.") then
                        CustomWorkflowHdr.Validate(CustomWorkflowHdr."Approval Status", CustomWorkflowHdr."Approval Status"::Rejected);
                    CustomWorkflowHdr.Modify(true);
                end;

        end;
    end;



    var
        WorkflowMgt: Codeunit "Workflow Management";
        RestrictionMgmt: Codeunit "Record Restriction Mgt.";
        RunWorkFlowOnSendForApprovalCode: label 'RUNWORKFLOWONSEND%1FORAPPROVAL';
        RunWorkFlowOnCancelForApprovalCode: label 'RUNWORKFLOWONCANCEL%1FORAPPROVAL';
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        WorkflowSendForApprovalEventDescTxt: Label 'Approval of %1 is requested.';
        WorkflowCancelForApprovalEventDescTxt: Label 'Approval of %1 is Cancelled.';
}
