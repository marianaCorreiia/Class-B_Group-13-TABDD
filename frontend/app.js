const statusDot = document.querySelector("#api-status-dot");
const statusLabel = document.querySelector("#api-status");
const destinationSelect = document.querySelector("#destination-select");
const typeSelect = document.querySelector("#type-select");
const searchInput = document.querySelector("#search-input");
const destinationForm = document.querySelector("#destination-form");
const nearbyForm = document.querySelector("#nearby-form");
const poiList = document.querySelector("#poi-list");
const feedback = document.querySelector("#feedback");
const resultCount = document.querySelector("#result-count");
const detail = document.querySelector("#poi-detail");
const reviewList = document.querySelector("#review-list");
const reviewCount = document.querySelector("#review-count");
const mapFrame = document.querySelector("#map-frame");
const mapLink = document.querySelector("#map-link");
let selectedPoiId = "";
let mode = "destination";
let poisById = new Map();

async function getJson(path) {
  const response = await fetch(path);
  const payload = await response.json();
  if (response.ok === false) {
    throw new Error(payload.detail || "O pedido não foi concluído.");
  }
  return payload;
}

function setStatus(online, message) {
  statusDot.classList.toggle("is-online", online);
  statusDot.classList.toggle("is-offline", online === false);
  statusLabel.textContent = message;
}

function setFeedback(message) {
  feedback.textContent = message;
}

function addOption(select, value, label) {
  const option = document.createElement("option");
  option.value = value;
  option.textContent = label;
  select.append(option);
}

async function loadDestinations() {
  const destinations = await getJson("/api/destinations");
  for (const destination of destinations) {
    addOption(destinationSelect, destination.id, destination.nome);
  }
}

function makePoiRow(poi) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "poi-row";
  button.dataset.poiId = poi.id;
  button.setAttribute("aria-label", `Ver ${poi.nome}`);

  const symbol = document.createElement("span");
  symbol.className = "poi-symbol";
  symbol.setAttribute("aria-hidden", "true");
  symbol.textContent = poi.tipo.slice(0, 1).toUpperCase();

  const text = document.createElement("span");
  const name = document.createElement("span");
  name.className = "poi-name";
  name.textContent = poi.nome;
  const meta = document.createElement("span");
  meta.className = "poi-meta";
  meta.textContent = `${poi.tipo} · ${poi.destino_nome || "Portugal"}`;
  text.append(name, meta);

  const rating = document.createElement("span");
  rating.className = "poi-rating";
  rating.textContent = poi.rating_medio ? `★ ${Number(poi.rating_medio).toFixed(1)}` : "POI";
  button.append(symbol, text, rating);
  button.addEventListener("click", () => selectPoi(poi.id));
  return button;
}

function renderPois(pois) {
  poisById = new Map(pois.map((poi) => [poi.id, poi]));
  poiList.replaceChildren(...pois.map(makePoiRow));
  resultCount.textContent = String(pois.length);
  if (pois.length === 0) {
    setFeedback("Não encontrámos resultados. Experimenta alterar os filtros ou o raio.");
    detail.innerHTML = "<p class=\"eyebrow\">DETALHE</p><h2>Sem resultados</h2><p class=\"muted\">Ajusta a pesquisa para explorar outros lugares.</p>";
    reviewList.replaceChildren();
    reviewCount.textContent = "0";
    return;
  }
  setFeedback(`${pois.length} ${pois.length === 1 ? "lugar encontrado" : "lugares encontrados"}`);
  selectPoi(pois[0].id);
}

async function loadDestinationPois() {
  const parameters = new URLSearchParams();
  if (destinationSelect.value) parameters.set("destino_id", destinationSelect.value);
  if (typeSelect.value) parameters.set("tipo", typeSelect.value);
  if (searchInput.value.trim()) parameters.set("termo", searchInput.value.trim());
  const suffix = parameters.size ? `?${parameters.toString()}` : "";
  renderPois(await getJson(`/api/pois${suffix}`));
}

async function loadNearbyPois() {
  const parameters = new URLSearchParams({
    latitude: document.querySelector("#latitude-input").value,
    longitude: document.querySelector("#longitude-input").value,
    raio_m: document.querySelector("#radius-select").value,
  });
  const type = document.querySelector("#nearby-type-select").value;
  if (type) parameters.set("tipo", type);
  renderPois(await getJson(`/api/pois/near?${parameters.toString()}`));
}

function updateMap(poi) {
  const coordinates = poi.localizacao && poi.localizacao.coordinates;
  if (coordinates === undefined || coordinates.length < 2) return;
  const longitude = Number(coordinates[0]);
  const latitude = Number(coordinates[1]);
  const bbox = `${longitude - 0.02},${latitude - 0.012},${longitude + 0.02},${latitude + 0.012}`;
  const parameters = new URLSearchParams({
    bbox,
    layer: "mapnik",
    marker: `${latitude},${longitude}`,
  });
  mapFrame.src = `https://www.openstreetmap.org/export/embed.html?${parameters.toString()}`;
  mapFrame.title = `Mapa centrado em ${poi.nome}`;
  mapLink.href = `https://www.openstreetmap.org/?mlat=${latitude}&mlon=${longitude}#map=16/${latitude}/${longitude}`;
}

function renderReviews(reviews) {
  reviewCount.textContent = String(reviews.length);
  if (reviews.length === 0) {
    reviewList.innerHTML = "<p class=\"muted\">Ainda não existem reviews para este lugar.</p>";
    return;
  }
  const items = reviews.map((review) => {
    const article = document.createElement("article");
    article.className = "review-item";
    const topline = document.createElement("div");
    topline.className = "review-topline";
    const author = document.createElement("span");
    author.className = "review-author";
    author.textContent = review.utilizador_nome || "Visitante";
    const rating = document.createElement("span");
    rating.className = "review-rating";
    rating.textContent = `${"★".repeat(Number(review.rating))} ${review.rating}/5`;
    topline.append(author, rating);
    const comment = document.createElement("p");
    comment.className = "review-comment";
    comment.textContent = review.comentario;
    article.append(topline, comment);
    return article;
  });
  reviewList.replaceChildren(...items);
}

async function selectPoi(poiId) {
  selectedPoiId = poiId;
  for (const row of poiList.querySelectorAll(".poi-row")) {
    row.classList.toggle("is-selected", row.dataset.poiId === poiId);
  }
  try {
    const [poi, reviews] = await Promise.all([
      getJson(`/api/pois/${encodeURIComponent(poiId)}`),
      getJson(`/api/reviews?alvo_tipo=POI&alvo_id=${encodeURIComponent(poiId)}`),
    ]);
    const heading = document.createElement("h2");
    heading.textContent = poi.nome;
    const description = document.createElement("p");
    description.className = "muted";
    description.textContent = poi.descricao || "Sem descrição disponível.";
    const eyebrow = document.createElement("p");
    eyebrow.className = "eyebrow";
    eyebrow.textContent = `${poi.tipo} · ${poi.destino_nome || "Portugal"}`;
    const meta = document.createElement("div");
    meta.className = "detail-meta";
    const price = document.createElement("span");
    price.textContent = poi.preco_nivel === undefined ? "Preço não indicado" : `Preço ${"€".repeat(Number(poi.preco_nivel)) || "gratuito"}`;
    const categories = document.createElement("span");
    categories.textContent = (poi.categorias || []).join(" · ");
    meta.append(price, categories);
    detail.replaceChildren(eyebrow, heading, description, meta);
    updateMap(poi);
    renderReviews(reviews);
  } catch (error) {
    setFeedback(error.message);
  }
}

function setMode(nextMode) {
  mode = nextMode;
  const destinationMode = mode === "destination";
  destinationForm.hidden = destinationMode === false;
  nearbyForm.hidden = destinationMode;
  document.querySelector("#mode-destination").classList.toggle("is-active", destinationMode);
  document.querySelector("#mode-destination").setAttribute("aria-selected", String(destinationMode));
  document.querySelector("#mode-nearby").classList.toggle("is-active", destinationMode === false);
  document.querySelector("#mode-nearby").setAttribute("aria-selected", String(destinationMode === false));
}

destinationForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  setFeedback("A pesquisar...");
  try {
    await loadDestinationPois();
  } catch (error) {
    setFeedback(error.message);
  }
});
nearbyForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  setFeedback("A procurar por proximidade...");
  try {
    await loadNearbyPois();
  } catch (error) {
    setFeedback(error.message);
  }
});
document.querySelector("#mode-destination").addEventListener("click", () => setMode("destination"));
document.querySelector("#mode-nearby").addEventListener("click", () => setMode("nearby"));
destinationSelect.addEventListener("change", () => destinationForm.requestSubmit());
typeSelect.addEventListener("change", () => destinationForm.requestSubmit());

async function start() {
  try {
    await getJson("/api/health");
    setStatus(true, "MongoDB ligado");
    await loadDestinations();
    await loadDestinationPois();
  } catch (error) {
    setStatus(false, "MongoDB indisponível");
    setFeedback(error.message);
  }
}

start();
