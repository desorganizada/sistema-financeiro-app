from datetime import date
import httpx
import ssl

from app.core.config import EXCHANGE_API_BASE_URL


def _extract_rate_from_payload(data, from_currency: str, to_currency: str):
    # Caso 1: resposta em lista
    if isinstance(data, list):
        for item in data:
            if not isinstance(item, dict):
                continue

            item_base = str(item.get("base", "")).upper().strip()
            item_quote = str(item.get("quote", "")).upper().strip()

            if item_base == from_currency and item_quote == to_currency:
                return item.get("rate"), item.get("date")

        # fallback: se veio um único item
        if len(data) == 1 and isinstance(data[0], dict):
            item = data[0]
            return item.get("rate"), item.get("date")

        return None, None

    # Caso 2: resposta em dict com quotes
    if isinstance(data, dict):
        quotes = data.get("quotes")
        if isinstance(quotes, dict):
            return quotes.get(to_currency), data.get("date")

        if isinstance(quotes, list):
            for item in quotes:
                if not isinstance(item, dict):
                    continue

                item_quote = (
                    str(
                        item.get("quote")
                        or item.get("quote_currency")
                        or item.get("currency")
                        or item.get("code")
                        or ""
                    )
                    .upper()
                    .strip()
                )

                if item_quote == to_currency:
                    return item.get("rate") or item.get("value"), item.get("date") or data.get("date")

            if len(quotes) == 1 and isinstance(quotes[0], dict):
                item = quotes[0]
                return item.get("rate") or item.get("value"), item.get("date") or data.get("date")

        rates = data.get("rates")
        if isinstance(rates, dict):
            return rates.get(to_currency), data.get("date")

    return None, None


async def fetch_exchange_rate_from_api(
    from_currency: str,
    to_currency: str,
    rate_date: date | None = None,
):
    from_currency = from_currency.upper().strip()
    to_currency = to_currency.upper().strip()
    base_url = EXCHANGE_API_BASE_URL.rstrip("/")

    # Se for a mesma moeda, retorna 1
    if from_currency == to_currency:
        return {
            "from_currency": from_currency,
            "to_currency": to_currency,
            "rate": 1.0,
            "rate_date": rate_date or date.today(),
        }, None

    endpoint = f"{base_url}/rates"

    params = {
        "base": from_currency,
        "quotes": to_currency,
    }

    if rate_date:
        params["date"] = rate_date.isoformat()

    try:
        # 🔧 SOLUÇÃO SSL: Configura o cliente para ignorar verificação SSL
        async with httpx.AsyncClient(
            timeout=20.0,
            verify=False,  # Ignora SSL para desenvolvimento
        ) as client:
            response = await client.get(endpoint, params=params)

            print("EXCHANGE API URL:", response.request.url)
            print("EXCHANGE API STATUS:", response.status_code)

            response.raise_for_status()
            data = response.json()
            print("EXCHANGE API BODY:", data)

        rate, result_date = _extract_rate_from_payload(
            data=data,
            from_currency=from_currency,
            to_currency=to_currency,
        )

        if rate is None:
            return None, (
                f"Cotação não encontrada na API externa para "
                f"{from_currency} -> {to_currency}"
            )

        if float(rate) <= 0:
            return None, (
                f"Cotação inválida na API externa para "
                f"{from_currency} -> {to_currency}"
            )

        return {
            "from_currency": from_currency,
            "to_currency": to_currency,
            "rate": rate,
            "rate_date": result_date or rate_date or date.today(),
        }, None

    except httpx.HTTPStatusError as e:
        try:
            error_data = e.response.json()
        except Exception:
            error_data = e.response.text

        print("EXCHANGE API ERROR URL:", e.request.url)
        print("EXCHANGE API ERROR STATUS:", e.response.status_code)
        print("EXCHANGE API ERROR BODY:", error_data)

        return None, f"Erro na API externa: {e.response.status_code} - {error_data}"

    except httpx.RequestError as e:
        print("EXCHANGE API REQUEST ERROR:", str(e))
        return None, "Erro de conexão com a API de cotação"

    except Exception as e:
        print("EXCHANGE API UNEXPECTED ERROR:", str(e))
        return None, f"Erro inesperado ao buscar cotação: {str(e)}"