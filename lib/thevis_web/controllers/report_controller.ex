defmodule ThevisWeb.ReportController do
  @moduledoc """
  Controller for PDF report generation and download.
  """

  use ThevisWeb, :controller

  alias Thevis.Projects
  alias Thevis.Reports.ReportGenerator

  @doc """
  Generates and downloads a PDF report for a project.
  """
  def download(conn, %{"project_id" => project_id, "scan_run_id" => scan_run_id})
      when scan_run_id != "" do
    project = Projects.get_project!(project_id)

    # Verify user has access to this project
    if authorized?(conn, project) do
      case ReportGenerator.generate_report(project, scan_run_id) do
        {:ok, pdf_binary} ->
          conn
          |> put_resp_content_type("application/pdf")
          |> put_resp_header(
            "content-disposition",
            "attachment; filename=\"geo-report-#{project_id}.pdf\""
          )
          |> send_resp(200, pdf_binary)

        {:error, :no_scan_run} ->
          conn
          |> put_flash(:error, "No scan run found for this project")
          |> redirect(to: ~p"/projects/#{project_id}")

        {:error, reason} ->
          conn
          |> put_flash(:error, "Failed to generate report: #{inspect(reason)}")
          |> redirect(to: ~p"/projects/#{project_id}")
      end
    else
      conn
      |> put_flash(:error, "You don't have access to this project")
      |> redirect(to: ~p"/dashboard")
    end
  end

  def download(conn, %{"project_id" => project_id}) do
    project = Projects.get_project!(project_id)

    # Verify user has access to this project
    if authorized?(conn, project) do
      case ReportGenerator.generate_report(project) do
        {:ok, pdf_binary} ->
          conn
          |> put_resp_content_type("application/pdf")
          |> put_resp_header(
            "content-disposition",
            "attachment; filename=\"geo-report-#{project_id}.pdf\""
          )
          |> send_resp(200, pdf_binary)

        {:error, :no_scan_run} ->
          conn
          |> put_flash(:error, "No completed scans found for this project")
          |> redirect(to: ~p"/projects/#{project_id}")

        {:error, reason} ->
          conn
          |> put_flash(:error, "Failed to generate report: #{inspect(reason)}")
          |> redirect(to: ~p"/projects/#{project_id}")
      end
    else
      conn
      |> put_flash(:error, "You don't have access to this project")
      |> redirect(to: ~p"/dashboard")
    end
  end

  # Check if current user is authorized to access this project
  defp authorized?(conn, project) do
    current_user = conn.assigns[:current_user]

    case current_user do
      nil -> false
      %{role: :consultant} -> true
      user -> Projects.user_has_access?(project, user)
    end
  end
end
