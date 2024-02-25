import { usePortalStore } from "./store";

function getAuthHeaders() {
  const { token } = usePortalStore.getState();
  if (!token) throw new Error("No auth token");

  return {
    Authorization: "Bearer " + token,
  };
}

function handleHttpResponse<T>(res: Response): Promise<T> {
  return new Promise((resolve, reject) => {
    if (res.ok) res.json().then(resolve).catch(reject);
    else reject(res)
  });
}

export async function httpGet<T>(path: string): Promise<T> {
  return await fetch(path, { headers: getAuthHeaders() }).then(
    handleHttpResponse<T>
  );
}

export async function httpPost<T>(path: string, body: object = {}): Promise<T> {
  return await fetch(path, {
    method: "post",
    body: JSON.stringify(body),
    headers: { ...getAuthHeaders(), "content-type": "application/json" },
  }).then(handleHttpResponse<T>);
}

export async function httpPut<T>(path: string, body: object = {}): Promise<T> {
  return await fetch(path, {
    method: "put",
    body: JSON.stringify(body),
    headers: { ...getAuthHeaders(), "content-type": "application/json" },
  }).then(handleHttpResponse<T>);
}

export async function httpDelete<T>(path: string): Promise<T> {
  return await fetch(path, { method: "delete", headers: getAuthHeaders() }).then(handleHttpResponse<T>);
}
