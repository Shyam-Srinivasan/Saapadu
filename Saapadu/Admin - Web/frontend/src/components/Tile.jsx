import React, {useEffect, useState} from "react";
import {Modal, Button, Form, Spinner} from "react-bootstrap";
import "./Tile.css";
import axios from "axios";
import {toast} from "react-toastify";
import {useNavigate} from "react-router-dom";
import {CreateTile} from "./CreateTile";
import "bootstrap-icons/font/bootstrap-icons.css";

export const Tile = ({
                         name = "",
                         id = "",
                         password = "",
                         image_path = "",
                         price = "",
                         stock_quantity = "",
                         type = "",
                         onUpdate,
                         onFetchDetails,
                         onSave,
                     }) => {
    const [showModal, setShowModal] = useState(false);
    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState("");
    const [form, setForm] = useState({name: "", password: "", image_path: "", price: "", stock_quantity: ""});
    const [college, setCollege] = useState(null);
    const [shop, setShop] = useState(null);
    const [category, setCategory] = useState(null);

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
    }, []);

    const handleClick = () => {
        localStorage.setItem(
            type,
            JSON.stringify(
                {
                    id: id,
                    name: name
                }
            )
        );
        if (type === "shop") {
            navigate('/categories');
        } else if (type === "category") {
            navigate('/items');
        }
    }

    const handleOpenEdit = async () => {
        setError("");
        setShowModal(true);
        try {
            setLoading(true);
            let details = {name, password, image_path, price, stock_quantity};
            if (typeof onFetchDetails === "function") {
                details = await onFetchDetails(id);
            } else if (id) {
                let res;
                if (type === "shop") {
                    res = await axios.get(`${API_BASE}/shopList/fetchShopById`, {
                        params: {shopId: id},
                        validateStatus: () => true,
                    });
                    if (res.status === 200) {
                        details = await res.data;
                    }
                } else if (type === "category") {
                    res = await axios.get(
                        `${API_BASE}/categoryList/fetchCategory`, {
                            params: {categoryId: id},
                            validateStatus: () => true,
                        });
                    if (res.status === 302) {
                        details = await res.data;
                    }
                } else if (type === "item") {
                    res = await axios.get(
                        `${API_BASE}/itemList/fetchItem`, {
                            params: {itemId: id},
                            validateStatus: () => true,
                        }
                    );
                    if (res.status === 302 || 303 || 202) {
                        details = await res.data;
                    }
                }
            }
            if (type === "shop") {
                setForm({
                    name: details?.shop_name ?? name,
                    password: details?.password ?? "",
                    image_path: details?.image_path ?? "",

                });
            } else if (type === "category") {
                setForm({
                    name: details?.category_name ?? name,
                    image_path: details?.image_path ?? "",
                });
            } else if (type === "item") {
                setForm({
                    name: details?.item_name ?? name,
                    image_path: details?.image_path ?? "",
                    price: details?.price ?? "",
                    stock_quantity: details?.stock_quantity ?? "",
                });
            }

        } catch (e) {
            if (type === "shop") {
                setError(`Failed to load Shop`);
                setForm({name, password, image_path});
            } else if (type === "category") {
                setError(`Failed to load Category`);
                setForm({name, image_path});
            } else if (type === "item") {
                setError(`Failed to load Item`);
                setForm({name, image_path, price, stock_quantity});
            }
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
            if (typeof onSave === "function") {
                await onSave({id, ...form});
            } else if (id) {
                let res;
                if (type === "shop") {
                    const payload = {
                        college_id: college?.id ?? college?.college_id ?? college?.collegeId,
                        shop_name: form.name,
                        password: form.password && form.password.trim() !== "" ? form.password : password,
                    };
                    res = await axios.put(
                        `${API_BASE}/shopList/updateShop`,
                        payload, {
                            params: {shopId: id},
                            validateStatus: () => true,
                        }
                    );
                    if (res.status === 201) {
                        toast.success("Shop updated!", {autoClose: 2000});
                        setShowModal(false);
                        if (typeof onUpdate === "function") await onUpdate();
                    } else {
                        toast.error(res.data || "Failed to update shop", {autoClose: 2000});
                    }
                } else if (type === "category") {
                    const payload = {
                        category_name: form.name,
                        image_path: form.image_path,
                        shop_id: shop?.id ?? shop?.shop_id,
                    };
                    res = await axios.put(
                        `${API_BASE}/categoryList/updateCategory`,
                        payload, {
                            params: {categoryId: id},
                            validateStatus: () => true,
                        }
                    );
                    if (res.status === 201) {
                        toast.success("Category updated!", {autoClose: 2000});
                        setShowModal(false);
                        if (typeof onUpdate === "function") await onUpdate();
                    } else {
                        toast.error(res.data || "Failed to update category", {autoClose: 2000});
                    }
                } else if (type === "item") {
                    const payload = {
                        category_id: category?.id ?? category?.category_id,
                        item_name: form.name,
                        image_path: form.image_path,
                        price: form.price,
                        stock_quantity: form.stock_quantity
                    };
                    res = await axios.put(
                        `${API_BASE}/itemList/updateItem`,
                        payload, {
                            params: {itemId: id},
                            validateStatus: () => true
                        }
                    );
                    if (res.status === 201) {
                        toast.success("Item updated!", {autoClose: 2000});
                        setShowModal(false);
                        if (typeof onUpdate === "function") await onUpdate();
                    } else {
                        toast.error(res.data || "Failed to update item", {autoClose: 2000});
                    }
                }
            }
        } catch (e) {
            setError("Failed to save changes.");
        } finally {
            setSaving(false);
        }
    };

    return (
        <>
            <div className="tile-card"
                 style={{cursor: "pointer"}}
                 onClick={handleClick}
                // onKeyDown={}
                 role="button"
                 tabIndex={0}
                 aria-label={`Open ${type}`}
            >
                <div className="tile-card__shine"/>
                <div className="tile-card__glow"/>
                <div className="tile-card__content">
                    <div className="tile-card__image"/>

                    <div className="tile-card__row">
                        <p className="tile-card__title" title={form.name || name}>
                            {name}
                        </p>

                        <button
                            type="button"
                            className="tile-card__edit"
                            aria-label={`Open ${type}`}
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
                </div>
            </div>

            <Modal show={showModal} onHide={handleClose} centered>
                <Modal.Header closeButton>
                    <Modal.Title>Edit {type === "shop" ? "Shop" : type === "category" ? "Category" : "Item"}</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    {loading ? (
                        <div className="d-flex align-items-center gap-2">
                            <Spinner animation="border" size="sm"/>
                            <span>Loading…</span>
                        </div>
                    ) : (
                        <>
                            {error && (
                                <div
                                    role="alert"
                                    className="alert alert-danger py-2 px-3 mb-3"
                                >
                                    {error}
                                </div>
                            )}
                            <Form>
                                <Form.Group controlId="name">
                                    <Form.Label>{type === "shop" ? "Shop Name" : type === "category" ? "Category Name" : "Item Name"}</Form.Label>
                                    <Form.Control
                                        type="text"
                                        value={form.name}
                                        onChange={(e) => setForm((f) => ({...f, name: e.target.value}))}
                                        placeholder={`Enter ${type === "shop" ? "shop" : "category"} name`}
                                        autoFocus
                                    />
                                </Form.Group>
                                {type === "shop" && (
                                    <Form.Group controlId="password">
                                        <Form.Label>Password</Form.Label>
                                        <div className="input-group">
                                            <Form.Control
                                                type={form.showPassword ? "text" : "password"}
                                                value={form.password}
                                                onChange={(e) => setForm((f) => ({...f, password: e.target.value}))}
                                                placeholder="Enter password"
                                                autoFocus
                                            />
                                            <button
                                                className="btn btn-outline-secondary"
                                                type="button"
                                                onClick={() =>
                                                    setForm((f) => ({...f, showPassword: !f.showPassword}))
                                                }
                                            >
                                                <i className={`bi bi-eye${form.showPassword ? "-slash" : ""}`}></i>
                                            </button>
                                        </div>
                                    </Form.Group>

                                )}

                                {(type === "category" || type === "item") && (
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
                                )}

                                {type === "item" && (
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
                                )}

                                {type === "item" && (
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
                                )}

                            </Form>
                        </>
                    )}
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={handleClose} disabled={saving}>
                        Cancel
                    </Button>
                    <Button variant="primary" onClick={handleSave} disabled={saving || loading}>
                        {saving ? (
                            <>
                                <Spinner
                                    as="span"
                                    animation="border"
                                    size="sm"
                                    role="status"
                                    aria-hidden="true"
                                    className="me-2"
                                />
                                Saving…
                            </>
                        ) : (
                            "Save"
                        )}
                    </Button>
                </Modal.Footer>
            </Modal>
        </>
    );
};