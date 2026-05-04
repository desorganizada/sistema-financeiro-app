from datetime import date
import httpx

from app.core.config import EXCHANGE_API_BASE_URL


async def fetch_exchange_rate_from_api(
    from_currency: str,
    to_currency: str,
    rate_date: date | None = None,
):
    from_currency = from_currency.upper().strip()
    to_currency = to_currency.upper().strip()

    if rate_date:
        endpoint = f"{EXCHANGE_API_BASE_URL}/{rate_date.isoformat()}"
    else:
        endpoint = f"{EXCHANGE_API_BASE_URL}/latest"

    async with httpx.AsyncClient(timeout=20.0) as client:
        try:
            # 🔹 tentativa direta
            params = {
                "base": from_currency,
                "symbols": to_currency,
            }

            response = await client.get(endpoint, params=params)
            response.raise_for_status()
            data = response.json()

            rates = data.get("rates", {})
            rate = rates.get(to_currency)

            if rate and rate > 0:
                return {
                    "from_currency": from_currency,
                    "to_currency": to_currency,
                    "rate": rate,
                    "rate_date": data.get("date"),
                }, None

            # 🔹 fallback: tentar inverso
            inverse_params = {
                "base": to_currency,
                "symbols": from_currency,
            }

            inverse_response = await client.get(endpoint, params=inverse_params)
            inverse_response.raise_for_status()
            inverse_data = inverse_response.json()

            inverse_rates = inverse_data.get("rates", {})
            inverse_rate = inverse_rates.get(from_currency)

            if inverse_rate and inverse_rate > 0:
                calculated_rate = 1 / inverse_rate

                return {
                    "from_currency": from_currency,
                    "to_currency": to_currency,
                    "rate": calculated_rate,
                    "rate_date": inverse_data.get("date"),
                }, None

            return None, f"Cotação não encontrada para {from_currency} -> {to_currency}"

        except httpx.RequestError:
            return None, "Erro de conexão com a API de cotação"

        except httpx.HTTPStatusError as e:
            return None, f"Erro na API externa: {e.response.status_code}"

        except Exception:
            return None, "Erro inesperado ao buscar cotação"