import React, {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import axios from "axios";
import {toast} from "react-toastify";
import {Button, Form, Modal, Spinner} from "react-bootstrap";

export const ItemTile = ({
                             name = "", id = "", image_path = "", price = "", stock_quantity = "", onUpdate,
                         }) => {

    const [showModal, setShowModal] = useState(false);
    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState("");
    const [form, setForm] = useState({name: "", password: "", image_path: "", price: "", stock_quantity: ""});
    const [college, setCollege] = useState(null);
    const [shop, setShop] = useState(null);
    const [category, setCategory] = useState(null);
    const [updatingStock, setUpdatingStock] = useState(false);
    const [liveStock, setLiveStock] = useState(stock_quantity);

    const API_BASE = `http://${window.location.hostname}:8080`;
    const navigate = useNavigate();

    useEffect(() => {
        try {
            const savedCollege = JSON.parse(localStorage.getItem("college"));
            const savedShop = JSON.parse(localStorage.getItem("shop"));
            const savedCategory = JSON.parse(localStorage.getItem("category"));
            setCollege(savedCollege);
            setShop(savedShop);
            setCategory(savedCategory);
        } catch {
            setCollege(null);
            setShop(null);
            setCategory(null);
        }

        const fetchStock = async () => {
            try {
                const res = await axios.get(`${API_BASE}/itemList/fetchItem`, {
                    params: {itemId: id},
                    validateStatus: () => true
                });
                if (res.status === 200 && res.data?.stock_quantity != null) {
                    setLiveStock(res.data.stock_quantity);
                    setForm((f) => ({...f, stock_quantity: res.data.stock_quantity}));
                }
            } catch (err) {
                alert("Failed to fetch stock", err);
            }
        };
        fetchStock();
    }, [id]);

    const handleOpenEdit = async () => {
        setError("");
        setShowModal(true);
        try {
            setLoading(true);
            let details = {name, image_path, price, stock_quantity};
            if (id) {
                const res = await axios.get(`${API_BASE}/itemList/fetchItem`, {
                    params: {itemId: id}, validateStatus: () => true,
                });
                if (res.status === 302) {
                    details = await res.data;
                }
            }
            setForm({
                name: details?.item_name ?? name,
                image_path: details?.image_path ?? "",
                price: details?.price ?? "",
                stock_quantity: details?.stock_quantity ?? "",
            });

        } catch (e) {
            setError(`Failed to load Item`);
            setForm({name, image_path, price, stock_quantity});
        } finally {
            setLoading(false);
        }
    };

    const handleClose = () => {
        if (!saving) {
            setShowModal(false);
            setError("");
        }
    };

    const handleSave = async () => {
        try {
            setSaving(true);
            setError("");
            if (id) {
                const payload = {
                    category_id: category?.id ?? category?.category_id,
                    item_name: form.name,
                    image_path: form.image_path,
                    price: form.price,
                    stock_quantity: form.stock_quantity
                };

                const res = await axios.put(`${API_BASE}/itemList/updateItem`, payload, {
                    params: {itemId: id}, validateStatus: () => true
                });
                if (res.status === 200) {
                    toast.success("Item updated!", {autoClose: 2000});
                    setShowModal(false);
                    if (typeof onUpdate === "function") await onUpdate();
                } else {
                    toast.error(res.data || "Failed to update item", {autoClose: 2000});
                }
            }

        } catch (e) {
            setError("Failed to save changes.");
        } finally {
            setSaving(false);
        }

    };

    const handleOutOfStock = async () => {
        try {
            setError("");
            if (stock_quantity !== 0) {
                const res = await axios.put(
                    `${API_BASE}/itemList/updateStockQuantity`,
                    null,
                    {
                        params: {
                            itemId: id,
                            stockQuantity: 0
                        },
                        validateStatus: () => true
                    }
                )

                if (res.status === 200) {
                    toast.success("Item updated!", {autoClose: 2000});
                    setShowModal(false);
                    if (typeof onUpdate === "function") await onUpdate();
                } else if (res.status === 500) {
                    toast.error(res.data || "Internal Server Error", {autoClose: 2000});
                } else {
                    toast.error("Unknown error occurred! Please try again later..", {autoClose: 2000});
                }
            } else {
                handleOpenEdit();
            }

        } catch {
            toast.error("Unknown error occurred! Please try again later...", {autoClose: 2000});
        }
    }

    const updateStock = async (newStock) => {
        try {
            setUpdatingStock(true);
            const res = await axios.put(
                `${API_BASE}/itemList/updateStockQuantity`,
                null,
                {
                    params: {itemId: id, stockQuantity: newStock},
                    validateStatus: () => true
                }
            );
            if (res.status === 200) {
                setLiveStock(newStock); // update live display
                setForm((f) => ({...f, stock_quantity: newStock}));
                if (typeof onUpdate === "function") onUpdate();
            } else {
                toast.error("Failed to update stock");
            }
        } catch (err) {
            toast.error("Server error");
            alert(err)
        } finally {
            setUpdatingStock(false);
        }
    };

    return (<>
        <div className="tile-card"
             style={{cursor: "pointer"}}
             role="button"
             tabIndex={0}
             aria-label={`Open Item`}
        >
            <div className="tile-card__shine"/>
            <div className="tile-card__glow"/>
            <div className="tile-card__content">
                <div className="tile-card__row">
                    <p className="tile-card__title" onClick={handleOutOfStock}
                       style={stock_quantity === 0 ? {color: "red"} : {color: "black"}} title={form.name || name}>
                        Out of Stock
                    </p>

                    <button
                        type="button"
                        className="tile-card__edit"
                        aria-label={`Open Item`}
                        onClick={(e) => {
                            e.stopPropagation();
                            handleOpenEdit();
                        }}
                    >
                        <svg
                            height="16"
                            width="16"
                            viewBox="0 0 24 24"
                            focusable="false"
                            aria-hidden="true"
                        >
                            <path
                                d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z"
                                fill="currentColor"
                            />
                            <path
                                d="M20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"
                                fill="currentColor"
                            />
                        </svg>
                    </button>
                </div>

                <div className="tile-card__image"/>

                <div className="tile-card__title">
                    <p className="tile-card__title" title={form.name || name}>
                        {name}
                    </p>
                </div>

                <div className="tile-card__row">
                    <p className="tile-card__title text-center" title={form.name || name}>
                        ₹{price}
                    </p>

                    <div className="quantity-button-wrapper">
                        <button
                            type="button"
                            className="quantity-btn"
                            disabled={updatingStock || liveStock <= 0}
                            onClick={(e) => {
                                e.stopPropagation();
                                if (liveStock > 0) updateStock(liveStock - 1);
                            }}
                        >
                            -
                        </button>

                        <span className="quantity-display">{liveStock}</span>

                        <button
                            type="button"
                            className="quantity-btn"
                            disabled={updatingStock}
                            onClick={(e) => {
                                e.stopPropagation();
                                updateStock(liveStock + 1);
                            }}
                        >
                            +
                        </button>
                    </div>


                </div>
            </div>
        </div>

        <Modal show={showModal} onHide={handleClose} centered>
            <Modal.Header closeButton>
                <Modal.Title>Edit Item</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                {loading ? (<div className="d-flex align-items-center gap-2">
                    <Spinner animation="border" size="sm"/>
                    <span>Loading…</span>
                </div>) : (<>
                    {error && (<div
                        role="alert"
                        className="alert alert-danger py-2 px-3 mb-3"
                    >
                        {error}
                    </div>)}
                    <Form>
                        <Form.Group controlId="name">
                            <Form.Label>Item Name</Form.Label>
                            <Form.Control
                                type="text"
                                value={form.name}
                                onChange={(e) => setForm((f) => ({...f, name: e.target.value}))}
                                placeholder={`Enter Item name`}
                                autoFocus
                            />
                        </Form.Group>

                        <Form.Group controlId="img_path">
                            <Form.Label>Image Path</Form.Label>
                            <Form.Control
                                type="text"
                                value={form.image_path}
                                onChange={(e) => setForm((f) => ({...f, image_path: e.target.value}))}
                                placeholder="Enter image path"
                                autoFocus
                            />
                        </Form.Group>


                        <Form.Group controlId="price">
                            <Form.Label>Price</Form.Label>
                            <Form.Control
                                type="number"
                                step="0.01"
                                value={form.price}
                                onChange={(e) => setForm((f) => ({...f, price: e.target.value}))}
                                placeholder="Enter price"
                                autoFocus
                            />
                        </Form.Group>


                        <Form.Group controlId="stock_quantity">
                            <Form.Label>Stock Quantity</Form.Label>
                            <Form.Control
                                type="number"
                                value={form.stock_quantity}
                                onChange={(e) => setForm((f) => ({...f, stock_quantity: e.target.value}))}
                                placeholder="Enter stock quantity"
                                autoFocus
                            />
                        </Form.Group>


                    </Form>
                </>)}
            </Modal.Body>
            <Modal.Footer>
                <Button variant="secondary" onClick={handleClose} disabled={saving}>
                    Cancel
                </Button>
                <Button variant="primary" onClick={handleSave} disabled={saving || loading}>
                    {saving ? (<>
                        <Spinner
                            as="span"
                            animation="border"
                            size="sm"
                            role="status"
                            aria-hidden="true"
                            className="me-2"
                        />
                        Saving…
                    </>) : ("Save")}
                </Button>
            </Modal.Footer>
        </Modal>
    </>);
}