import os
from datetime import datetime
from typing import Dict, Any, Optional
from core.config import settings
from database.supabase_client import db_service

try:
    from sendgrid import SendGridAPIClient
    from sendgrid.helpers.mail import Mail, Email, To, Content
    SENDGRID_AVAILABLE = True
except ImportError:
    SENDGRID_AVAILABLE = False


class EmailNotificationService:
    def __init__(self):
        self.api_key = settings.SENDGRID_API_KEY
        self.from_email = settings.SENDGRID_FROM_EMAIL
        self.client = None
        if SENDGRID_AVAILABLE and self.api_key and not self.api_key.startswith("SG.dummy") and len(self.api_key) > 10:
            try:
                self.client = SendGridAPIClient(self.api_key)
                print("SendGrid API client initialized successfully.")
            except Exception as e:
                print(f"SendGrid client init error: {e}")

    def send_email(self, to_email: str, subject: str, html_content: str, email_type: str = "NOTIFICATION") -> Dict[str, Any]:
        """
        Sends an email via SendGrid or records it in the dispatch log with full HTML preview.
        """
        record = {
            "to": to_email,
            "subject": subject,
            "type": email_type,
            "sent_at": datetime.now().isoformat(),
            "status": "QUEUED"
        }

        if self.client:
            try:
                message = Mail(
                    from_email=self.from_email,
                    to_emails=to_email,
                    subject=subject,
                    html_content=html_content
                )
                response = self.client.send(message)
                record["status"] = "DELIVERED"
                record["status_code"] = response.status_code
                print(f"[SendGrid] Sent email to {to_email} (Code {response.status_code})")
            except Exception as e:
                print(f"[SendGrid API Error] {e}. Falling back to transactional log.")
                record["status"] = "SIMULATED_SUCCESS"
                record["error_note"] = str(e)
        else:
            # Simulated environment: records dispatched email
            record["status"] = "SIMULATED_SUCCESS"
            record["delivery_note"] = "Recorded in transactional dispatch queue (Configure SENDGRID_API_KEY in .env for live SMTP delivery)."

        db_service.dispatched_emails.insert(0, record)
        return record

    def send_task_deadline_alert(self, engineer_email: str, engineer_name: str, task_title: str, due_date: str, project_title: str):
        subject = f"[CRITICAL DEADLINE] Task Due Soon: {task_title}"
        html = f"""
        <div style="font-family: 'Helvetica Neue', Arial, sans-serif; background:#0F172A; color:#F8FAFC; padding:32px; border-radius:12px; max-width:600px; margin:0 auto; border:1px solid #334155;">
            <div style="border-bottom: 2px solid #D4AF37; padding-bottom: 16px; margin-bottom: 24px;">
                <h1 style="color:#D4AF37; margin:0; font-size:24px; letter-spacing:1px;">INTERIORCRAFT STUDIO</h1>
                <p style="color:#94A3B8; margin:4px 0 0 0; font-size:13px;">Automated Site Alert System</p>
            </div>
            <h2 style="color:#F8FAFC; font-size:18px;">Upcoming Task Deadline Alert</h2>
            <p>Dear {engineer_name},</p>
            <p>This is an automated reminder that the following site task is scheduled for completion:</p>
            <div style="background:#1E293B; border-left:4px solid #F59E0B; padding:16px; border-radius:6px; margin:18px 0;">
                <p style="margin:0 0 8px 0; font-size:15px; font-weight:bold; color:#F8FAFC;">{task_title}</p>
                <p style="margin:0 0 4px 0; font-size:13px; color:#94A3B8;">Project: <strong style="color:#E2E8F0;">{project_title}</strong></p>
                <p style="margin:0; font-size:13px; color:#F59E0B;">Target Deadline: <strong>{due_date}</strong></p>
            </div>
            <p style="font-size:13px; color:#94A3B8;">Please submit progress photos and site notes through the Engineer Portal upon completion.</p>
        </div>
        """
        return self.send_email(engineer_email, subject, html, "DEADLINE_ALERT")

    def send_ai_delay_warning(self, owner_email: str, project_title: str, delay_days: float, delay_probability: float, recommendation: str):
        subject = f"[AI RISK ALERT] Schedule Variance Flagged: {project_title}"
        html = f"""
        <div style="font-family: 'Helvetica Neue', Arial, sans-serif; background:#0F172A; color:#F8FAFC; padding:32px; border-radius:12px; max-width:600px; margin:0 auto; border:1px solid #334155;">
            <div style="border-bottom: 2px solid #D4AF37; padding-bottom: 16px; margin-bottom: 24px;">
                <h1 style="color:#D4AF37; margin:0; font-size:24px; letter-spacing:1px;">INTERIORCRAFT STUDIO</h1>
                <p style="color:#94A3B8; margin:4px 0 0 0; font-size:13px;">AI Predictive Engine Advisory</p>
            </div>
            <h2 style="color:#EF4444; font-size:18px;">Automated Site Delay Forecast</h2>
            <p>Dear Elena (Studio Owner),</p>
            <p>Our machine learning engine has evaluated ongoing tasks, material lead times, and trade velocity for <strong>{project_title}</strong>.</p>
            <div style="background:#1E293B; border-left:4px solid #EF4444; padding:16px; border-radius:6px; margin:18px 0;">
                <p style="margin:0 0 8px 0; font-size:14px; color:#94A3B8;">Forecasted Delay: <span style="color:#EF4444; font-weight:bold; font-size:16px;">+{delay_days} Business Days</span></p>
                <p style="margin:0 0 8px 0; font-size:14px; color:#94A3B8;">Model Delay Probability: <span style="color:#F59E0B; font-weight:bold;">{delay_probability}%</span></p>
                <p style="margin:0; font-size:13px; color:#E2E8F0;"><strong>AI Recommendation:</strong> {recommendation}</p>
            </div>
        </div>
        """
        return self.send_email(owner_email, subject, html, "AI_DELAY_WARNING")

    def send_payment_milestone_invoice(self, client_email: str, client_name: str, invoice_number: str, milestone_name: str, amount: float, due_date: str):
        subject = f"Invoice Available for Milestone: {milestone_name} ({invoice_number})"
        html = f"""
        <div style="font-family: 'Helvetica Neue', Arial, sans-serif; background:#0F172A; color:#F8FAFC; padding:32px; border-radius:12px; max-width:600px; margin:0 auto; border:1px solid #334155;">
            <div style="border-bottom: 2px solid #D4AF37; padding-bottom: 16px; margin-bottom: 24px;">
                <h1 style="color:#D4AF37; margin:0; font-size:24px; letter-spacing:1px;">INTERIORCRAFT STUDIO</h1>
                <p style="color:#94A3B8; margin:4px 0 0 0; font-size:13px;">Client Billing & Financial Services</p>
            </div>
            <h2 style="color:#F8FAFC; font-size:18px;">Milestone Invoice Notice</h2>
            <p>Dear {client_name},</p>
            <p>We are delighted to share that your interior design project has reached the milestone: <strong>{milestone_name}</strong>.</p>
            <div style="background:#1E293B; border:1px solid #D4AF37; padding:20px; border-radius:8px; margin:20px 0; text-align:center;">
                <p style="color:#94A3B8; margin:0 0 4px 0; font-size:13px;">Invoice Number: {invoice_number}</p>
                <h1 style="color:#D4AF37; margin:4px 0; font-size:32px;">${amount:,.2f}</h1>
                <p style="color:#F59E0B; margin:0; font-size:13px;">Due Date: {due_date}</p>
            </div>
            <p style="font-size:13px; color:#94A3B8;">You can view the detailed breakdown and submit payment securely through your Client Portal.</p>
        </div>
        """
        return self.send_email(client_email, subject, html, "PAYMENT_MILESTONE")

email_service = EmailNotificationService()
