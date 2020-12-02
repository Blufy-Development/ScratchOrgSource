import { LightningElement, api} from 'lwc';

export default class EnrollmentSummary extends LightningElement {
    @api studetnDetailsArr;
    @api enrolTotalAmt
}